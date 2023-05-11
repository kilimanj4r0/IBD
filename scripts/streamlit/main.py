# pylint: disable=C0103, no-value-for-parameter, missing-docstring, no-member
import json

from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd
import streamlit as st

from scripts.streamlit.utils import load_dataset

streamlit_path = Path(__file__).parent
ibd_path = streamlit_path.parent.parent
output_path = ibd_path / 'output'
data_path = ibd_path / 'data'
eda_path = output_path / 'eda'

with (streamlit_path / 'texts.json').open('rb') as f:
    texts = json.load(f)

st.title("Startups DA")
st.write("**Big Data project**")
st.write("Batalov Artem, Makharev Vladimir, BS20-AI-01")

st.header("Project info")
st.subheader("Goal")
st.write(texts['goal'])
st.subheader("Data information")
st.write('The dataset contains one main table and some helping tables.')

companies, people, products, financial_orgs \
      = load_dataset(data_path / 'objects.csv')

for name, df in [
        ('Companies', companies),
        ('People', people),
        ('Products', products),
        ('Financial Orgs', financial_orgs),
]:
    st.write("**{}:**".format(name))
    st.write("Shape: ", df.shape)
    st.write(df.head())
    st.write(df.describe())

st.header("Exploratory Data Analysis")

st.subheader('1. Average funding (in million $) by categories')
st.write(texts["eda1"])
q1 = pd.read_csv(eda_path / "q1.csv") \
    .sort_values('avg_funding_m', ascending=False)

fig, ax = plt.subplots(figsize=(15, 6))
ax.bar(q1['category_code'], q1['avg_funding_m'], align='center')
fig.autofmt_xdate(rotation=90)
st.pyplot(fig)

st.subheader('2. Average funding (in million $) by startup registration country')
st.write(texts["eda2"])
q2 = pd.read_csv(eda_path / "q2.csv") \
         .sort_values('avg_funding_m', ascending=False)[:30]

fig, ax = plt.subplots(figsize=(15, 6))
ax.bar(q2['country_code'], q2['avg_funding_m'], align='center')
fig.autofmt_xdate(rotation=90)
st.pyplot(fig)

st.subheader('3. Check correlation between count of employees and company total fundings')
st.write(texts["eda3"])
q3 = pd.read_csv(eda_path / "q3.csv")
o_q3 = q3
q3 = q3[q3['employees'] < 200]
q3 = q3[q3['funding_total_usd'] < 1e9]

fig, ax = plt.subplots()
ax.scatter(q3['employees'], q3['funding_total_usd'], alpha=0.3)
ax.set_xlabel('employees')
ax.set_ylabel('funding_total_usd')
st.pyplot(fig)

st.write('Pearson:', o_q3.corr('pearson'))
st.write('Spearman:', o_q3.corr('spearman'))

st.write(texts["hyp"])

st.subheader('4. Check average funding or companies connected with person by their education')
st.write(texts["eda4"])
q4 = pd.read_csv(eda_path / "q4.csv") \
         .sort_values('avg_degree_fundings', ascending=False)[:30]

fig, ax = plt.subplots(figsize=(15, 6))
ax.bar(q4['degree_type'], q4['avg_degree_fundings'], align='center')
fig.autofmt_xdate(rotation=90)
st.pyplot(fig)

st.subheader('5. Funding by company year of foundation')
st.write(texts["eda5"])
q5 = pd.read_csv(eda_path / "q5.csv") \
         .sort_values('year')[:30]

fig, ax = plt.subplots(figsize=(15, 6))
ax.bar(q5['year'], q5['sum_raised'], align='center')
fig.autofmt_xdate(rotation=90)
st.pyplot(fig)

st.header("Predictive Data Analysis")
st.subheader("Feature engineering")
st.write('''
- Based on main (`objects`) table
- Performed group by `entity_type`
- Aggregated number of products per status, number of employees
and product names
''')

st.subheader("Preprocessing")
st.write('''
- Dropped null values
- Encoded dates via Circular encoding
- Encoded text features via Word2Vec
- Encoded categorical features via Ordinal encoding
- Applied MinMaxScaler to the features vector
''')

st.subheader("Polynomial Linear Regression")

st.write('''
Best model params obtained from grid search: `degree=2, elasticNetParam=0.0` 

**On test data:** 

RMSE: `1025627087.4436382`  
$R^2$: `-110.65749935598437`

**On train data:**

RMSE: `22469357.53576915`  
$R^2$: `0.8831709227220857`
''')
pred = pd.read_csv('output/pred/plr_pred.csv')
st.write(pred)

st.subheader("Decision Tree Regressor")

st.write('''
Best model parameters obtained from grid search: 
`minBins=128, maxDepth=30, minInstancesPerNode=10`

**On test data:**

RMSE: `96765657.17915614`  
$R^2$: `0.006079991136756169`

**On train data:**

RMSE: `48338713.67334328`  
$R^2$: `0.45929570963974675`
''')
pred = pd.read_csv('output/pred/dt_pred.csv')
st.write(pred)

st.write('''Therefore, the Descision Tree Regressor shows 
better performance on the test data.''')
