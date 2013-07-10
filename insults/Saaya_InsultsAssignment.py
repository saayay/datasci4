import sklearn
import pandas as pd
import numpy as np

### Load train.csv file 

df = pd.read_csv(r"/Users/saaya1/data_science/instr_repo/GADS4/data/insults/train.csv")

### Split the data into train and test.

from sklearn.cross_validation import train_test_split
from sklearn.feature_extraction.text import CountVectorizer

df_train, df_test = train_test_split(df, train_size=0.6, test_size=0.4)

vec = CountVectorizer(stop_words='english')

train_target = df_train[:,0]
train_data = vec.fit_transform(df_train[:,-1])
test_target = df_test[:,0]
test_data = vec.transform(df_test[:,-1])

if not len(train_target) == len(train_data.toarray()) or not len(test_target) == len(test_data.toarray()):
    raise Exception("Error")

    
### Logistic Regression

#train
from sklearn import linear_model
from sklearn.cross_validation import cross_val_score

modelL = linear_model.LogisticRegression()
modelL = modelL.fit(train_data, train_target)
modelL.score(train_data, train_target)
cross_val_score(modelL, train_data.toarray(), train_target, cv=10)

#test
from sklearn.metrics import auc_score
cross_val_score(modelL, test_data.toarray(), test_target, cv=10)

test_score = modelL.predict_proba(test_data)
auc_score(test_target, test_score[:,1])


### Naive Bayes Model

#train
from sklearn.naive_bayes import MultinomialNB

modelN = MultinomialNB()
modelN = modelN.fit(train_data, train_target)
modelN.score(train_data, train_target)
cross_val_score(modelN, train_data.toarray(), train_target, cv=10)

#test
cross_val_score(modelN, test_data.toarray(), test_target, cv=10)

test_score = modelN.predict_proba(test_data)
auc_score(test_target, test_score[:,1])


### Load test.csv file and test
df2 = pd.read_csv(r"/Users/saaya1/data_science/instr_repo/GADS4/data/insults/test.csv", header=None)
df_finalTest = df2.ix[1:]

finalTest_data = vec.transform(df_finalTest.iloc[:,-1])

final_score = modelL.predict_proba(finalTest_data)

### Create a CSV file
df_id = df_finalTest.iloc[:,0]
score = final_score[:,1]

d = {'Id' : df_id,
    'Insult': score}
final = pd.DataFrame(d)

final.to_csv('/Users/saaya1/data_science/datasci4/insults/Saaya_InsultsAssignment.csv', index=False)




