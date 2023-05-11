import pyspark.sql.functions as F
from pyspark.sql import SparkSession
from pyspark.ml import Pipeline
from date_transformer import DateTransformer
from pyspark.ml.feature import Word2Vec, StringIndexer, VectorAssembler, MinMaxScaler, PolynomialExpansion
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
from pyspark.ml.regression import LinearRegression, DecisionTreeRegressor


spark = SparkSession.builder\
        .appName("Startups DA")\
        .config("spark.sql.catalogImplementation","hive")\
        .config("hive.metastore.uris", "thrift://sandbox-hdp.hortonworks.com:9083")\
        .config("spark.sql.avro.compression.codec", "snappy")\
        .enableHiveSupport()\
        .getOrCreate()

# Feature engineering
objects = spark.read.format("avro").option("encoding", "UTF-8").table('projectdb.objects')
print(objects.schema)
1/0
objects.show(1, vertical=True)

objects.select('entity_type').distinct().show()

objects = objects.drop("created_by", "created_at", "updated_at", "logo_url", "logo_width", "logo_height", "permalink","name", "entity_id", "twitter_username", "domain", "homepage_url")
objects.show(1, vertical=True)


def get_by_entity_type(df, entity_type):
    return df[df["entity_type"] == entity_type].drop("entity_type").na.drop(how="all")


companies = get_by_entity_type(objects, 'Company')
people = get_by_entity_type(objects, 'Person')
products = get_by_entity_type(objects, 'Product')
financial_orgs = get_by_entity_type(objects, 'FinancialOrg')

# Building main table companies
companies = companies.drop("first_funding_at", "last_funding_at", "funding_rounds")
companies.show(1, vertical=True)

companies.select("short_description").na.fill("")
companies.select("description").na.fill("")
companies.select("overview").na.fill("")

companies = companies.withColumn("description", F.concat_ws(" ", companies["short_description"], companies["description"], companies["overview"]))
companies = companies.drop("short_description", "overview")
companies.show(1, vertical=True)

products = products.drop("region", "investment_rounds", "invested_companies", "funding_rounds", "funding_total_usd", "relationships")

products_by_parent = (
    products.groupBy("parent_id", "status")
    .count()
    .groupBy("parent_id")
    .pivot("status")
    .sum("count")
)
companies = companies.join(products_by_parent.withColumnRenamed('parent_id', 'id'), on="id", how='left')
companies.show(5, vertical=True)

products.select("normalized_name").na.fill("")
products_by_parent = (
    products.groupBy("parent_id")
    .agg(F.concat_ws(" ", F.collect_list("normalized_name")).alias("product_names"))
)
companies = companies.join(products_by_parent.withColumnRenamed('parent_id', 'id'), on="id", how='left')
companies.show(5, vertical=True)

relationships = spark.read.format("avro").option("encoding", "UTF-8").table('projectdb.relationships')
relationships.printSchema()

relationship_by_object = relationships.groupBy('relationship_object_id').agg(F.count('id').alias("employees"))
companies = companies.join(relationship_by_object.withColumnRenamed('relationship_object_id', 'id'), on="id", how='left')
companies.show(5, vertical=True)

# Preprocessing
companies.printSchema()
companies_ = companies.drop('id', 'parent_id', 'status', 'state_code', 'city', 'region')
companies_.show(20)
print(companies_.columns)

date_columns = ['founded_at', 'closed_at', 'first_investment_at', 'last_investment_at', 'first_milestone_at', 'last_milestone_at']
for column in date_columns:
    companies_ = companies_.withColumn(column, F.from_unixtime(F.col(column) / 1000, "yyyy-MM-dd").cast("date"))

text_columns = ['normalized_name', 'description', 'tag_list', 'product_names']
companies_ = companies_.withColumn('tag_list', F.regexp_replace('tag_list', ',', ''))

categorical_columns = ['category_code', 'country_code']

companies_ = companies_.fillna(0, subset=['alpha', 'beta', 'closed', 'development', 'live', 'operating', 'private', 'employees'])
companies_ = companies_.fillna("No", subset=categorical_columns)
companies_.show(5, vertical=True)

# Encoding dates
for column in date_columns:
    print(column)
    date_transformer = DateTransformer(input_col=column)
    pipeline = Pipeline(stages=[date_transformer])
    model = pipeline.fit(companies_)
    companies_ = model.transform(companies_)
for column in date_columns:
    companies_ = companies_.fillna(0, subset=[column+'_year', column+'_month_cos', column+'_month_sin'])
companies_.show(5)

# Encoding texts
for column in text_columns:
    companies_ = companies_.filter(F.col(column).isNotNull())
for column in text_columns:
    companies_ = companies_.withColumn(column, F.slice(F.split(column, ' '), 1, 10))
companies_.show(5, vertical=True)

for column in text_columns:
  word2Vec = Word2Vec(vectorSize=20, minCount=0, inputCol=column, outputCol=column+"_", seed=42)
  model = word2Vec.fit(companies_)
  companies_ = model.transform(companies_)
  companies_ = companies_.drop(column)
companies_.show(5, vertical=True)

# Encoding categorical
for column in categorical_columns:
    indexer = StringIndexer(inputCol=column, outputCol=column + '_').setHandleInvalid("skip")
    model = indexer.fit(companies_)
    companies_ = model.transform(companies_)
    companies_ = companies_.drop(column)
companies_.show(5, vertical=True)

# Modeling
target_col = 'funding_total_usd'
companies_ = companies_.withColumn(target_col, F.col(target_col).cast('double'))
companies_ = companies_.filter(F.col(target_col).isNotNull())
companies_ = companies_.filter(F.col(target_col) != 0.0)
companies_.printSchema()

selected_cols = companies_.columns
selected_cols.remove(target_col)

assembler = VectorAssembler(inputCols=selected_cols, outputCol="features")
scaler = MinMaxScaler(inputCol="features", outputCol="scaledFeatures")

pipeline = Pipeline(stages=[assembler, scaler])
companies_transformed = pipeline.fit(companies_).transform(companies_)

companies_transformed = companies_transformed.drop('features').withColumnRenamed("scaledFeatures", "features").select("features", target_col)
companies_transformed.show(1, vertical=True, truncate=False)

# Data splitting
(train_data, test_data) = companies_transformed.randomSplit([0.7, 0.3], seed=42)

rmse_evaluator = RegressionEvaluator(labelCol=target_col, predictionCol="prediction", metricName="rmse")
r2_evaluator = RegressionEvaluator(labelCol=target_col, predictionCol="prediction", metricName="r2")

# # Polynomial Linear Regression
# polyExpansion = PolynomialExpansion(degree=2, inputCol="features", outputCol="polyFeatures")
# lr = LinearRegression(featuresCol="polyFeatures", labelCol=target_col)

# plr_pipeline = Pipeline(stages=[polyExpansion, lr])
# plr_param_grid = ParamGridBuilder() \
#     .addGrid(PolynomialExpansion.degree, [2, 3, 4]) \
#     .addGrid(LinearRegression.elasticNetParam, [0.0, 0.5, 1]) \
#     .build()
# plr_cross_validator = CrossValidator(estimator=plr_pipeline,
#                                  estimatorParamMaps=plr_param_grid,
#                                  evaluator=RegressionEvaluator(labelCol=target_col),
#                                  numFolds=4,
#                                  seed=42)
# plr_model = plr_cross_validator.fit(train_data)
# best_plr_model = plr_model.bestModel
# print("Best PLR params: ", best_plr_model.stages[0].getDegree(), best_plr_model.stages[1].getElasticNetParam())

# best_plr_model.save("/root/IBD/models/plr_model")

# # Evaluate on train
# plr_predictions = best_plr_model.transform(train_data)
# plr_rmse = rmse_evaluator.evaluate(plr_predictions)
# plr_r2 = r2_evaluator.evaluate(plr_predictions)
# print("PLR RMSE on train data:", plr_rmse)
# print("PLR R2 on train data:", plr_r2)

# # Evaluate on test
# plr_predictions = best_plr_model.transform(test_data)
# plr_rmse = rmse_evaluator.evaluate(plr_predictions)
# plr_r2 = r2_evaluator.evaluate(plr_predictions)
# print("PLR RMSE on test data:", plr_rmse)
# print("PLR R2 on test data:", plr_r2)

# # Save predictions
# plr_predictions.repartition(1)\
#     .select("prediction", target_col)\
#     .write\
#     .mode("overwrite")\
#     .format("csv")\
#     .option("sep", ",")\
#     .option("header","true")\
#     .csv("/root/IBD/output/plr_predictions.csv")


# # Decision Tree Regressor
# dt = DecisionTreeRegressor(featuresCol="features", labelCol=target_col, maxBins=128)

# dt_param_grid = ParamGridBuilder() \
#     .addGrid(dt.maxDepth, [15, 30]) \
#     .addGrid(dt.minInstancesPerNode, [1, 10]) \
#     .build()
# dt_cross_validator = CrossValidator(estimator=dt,
#                           estimatorParamMaps=dt_param_grid,
#                           evaluator=RegressionEvaluator(labelCol=target_col),
#                           numFolds=4,
#                           seed=42)
# dt_model = dt_cross_validator.fit(train_data)
# best_dt_model = dt_model.bestModel
# print("Best DT params: ", best_dt_model.getMaxDepth(), best_dt_model.getMinInstancesPerNode())

# best_dt_model.save("/root/IBD/models/dt_model")

# # Evaluate on train
# dt_predictions = best_dt_model.transform(train_data)
# dt_rmse = rmse_evaluator.evaluate(dt_predictions)
# dt_r2 = r2_evaluator.evaluate(dt_predictions)
# print("DT RMSE on train data:", dt_rmse)
# print("DT R2 on train data:", dt_r2)

# # Evaluate on test
# dt_predictions = best_dt_model.transform(test_data)
# dt_rmse = rmse_evaluator.evaluate(dt_predictions)
# dt_r2 = r2_evaluator.evaluate(dt_predictions)
# print("DT RMSE on test data:", dt_rmse)
# print("DT R2 on test data:", dt_r2)

# # Save predictions
# dt_predictions.repartition(1)\
#     .select("prediction", target_col)\
#     .write\
#     .mode("overwrite")\
#     .format("csv")\
#     .option("sep", ",")\
#     .option("header","true")\
#     .csv("/root/IBD/output/dt_predictions.csv")