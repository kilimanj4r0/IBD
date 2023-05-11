from pyspark import keyword_only
from pyspark.ml import Transformer
from pyspark.ml.param.shared import HasInputCol, HasOutputCol, Param, Params, TypeConverters
from pyspark.ml.util import DefaultParamsReadable, DefaultParamsWritable
from pyspark.sql.types import DoubleType
import pyspark.sql.functions as F
import math


class DateTransformer(Transformer, HasInputCol, HasOutputCol, DefaultParamsReadable, DefaultParamsWritable):
    input_col = Param(Params._dummy(), "input_col", "input column name.", typeConverter=TypeConverters.toString)
    
    @keyword_only
    def __init__(self, input_col="input"):
        super(DateTransformer, self).__init__()
        self._setDefault(input_col=None)
        kwargs = self._input_kwargs
        self.set_params(**kwargs)
    
    @keyword_only
    def set_params(self, input_col="input"):
        kwargs = self._input_kwargs
        self._set(**kwargs)
    
    def get_input_col(self):
        return self.getOrDefault(self.input_col)
    
    def _transform(self, df):
        input_col = self.get_input_col()
        
        month_cos_udf = F.udf(lambda month: math.cos(2*math.pi*float(month)/12.0) if month is not None else None, DoubleType())
        month_sin_udf = F.udf(lambda month: math.sin(2*math.pi*float(month)/12.0) if month is not None else None, DoubleType())
        
        # Extract month and year components
        df = df.withColumn("month", F.month(input_col))
        df = df.withColumn(input_col + '_year', F.year(input_col))
        
        # Convert month to vector
        df = df.withColumn(input_col + '_month_cos', month_cos_udf(F.col("month")))
        df = df.withColumn(input_col + '_month_sin', month_sin_udf(F.col("month")))
        
        # Drop intermediate columns
        df = df.drop("month", input_col)
        
        return df