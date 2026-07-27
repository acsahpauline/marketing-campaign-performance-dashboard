import pandas as pd

df = pd.read_csv("data/raw/marketing_campaign.csv", sep=";")

df = df.dropna(subset=["Income"])

df["age"] = 2026 - df["Year_Birth"]

df["Dt_Customer"] = pd.to_datetime(df["Dt_Customer"], format="%Y-%m-%d")
df["customer_tenure_days"] = (pd.Timestamp("2026-01-01") - df["Dt_Customer"]).dt.days

spend_columns = ["MntWines", "MntFruits", "MntMeatProducts", "MntFishProducts", "MntSweetProducts", "MntGoldProds"]
df["total_spend"] = df[spend_columns].sum(axis=1)

campaign_columns = ["AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3", "AcceptedCmp4", "AcceptedCmp5"]
df["total_campaigns_accepted"] = df[campaign_columns].sum(axis=1)

df["family_size"] = df["Kidhome"] + df["Teenhome"] + df["Marital_Status"].isin(["Married", "Together"]).astype(int) + 1

def income_bracket(income):
    if income < 30000:
        return "Low"
    elif income < 60000:
        return "Mid"
    elif income < 90000:
        return "High"
    else:
        return "Very High"

df["income_bracket"] = df["Income"].apply(income_bracket)

def age_group(age):
    if age < 30:
        return "20s"
    elif age < 40:
        return "30s"
    elif age < 50:
        return "40s"
    elif age < 60:
        return "50s"
    else:
        return "60+"

df["age_group"] = df["age"].apply(age_group)

df.columns = [col.lower() for col in df.columns]

df.to_csv("data/staging/marketing_cleaned.csv", index=False)

print(f"Total rows after cleaning: {len(df)}")
print(df[["age", "total_spend", "total_campaigns_accepted", "family_size", "income_bracket", "age_group"]].head(10))