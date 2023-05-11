# pylint: disable=missing-docstring
import pandas as pd


def get_by_entity_type(data, entity_type):
    """Get dataframe by entity type"""
    return (
        data[data["entity_type"] == entity_type]
        .drop(columns=["entity_type"])
        .dropna(axis=1, how="all")
    )


def load_dataset(path):
    objects_df = pd.read_csv(
        path,
        dtype={
            "parent_id": "object",
            "category_code": "object",
            "short_description": "object",
            "description": "object",
            "country_code": "object",
            "state_code": "object",
            "city": "object",
            "created_by": "object",
        },
        parse_dates=[9, 10, 25, 26, 29, 30, 33, 34],
    ).drop(
        columns=[
            "created_by",
            "created_at",
            "updated_at",
            "logo_url",
            "logo_width",
            "logo_height",
            "permalink",
            "name",
            "entity_id",
            "twitter_username",
            "domain",
            "homepage_url",
        ]
    )

    companies = get_by_entity_type(objects_df, 'Company')
    people = get_by_entity_type(objects_df, 'Person')
    products = get_by_entity_type(objects_df, 'Product')
    financial_orgs = get_by_entity_type(objects_df, 'FinancialOrg')

    companies.drop(
        columns=[
            "first_funding_at",
            "last_funding_at",
            "funding_rounds",
        ],
        inplace=True,
    )

    people.drop(
        columns=["funding_rounds", "funding_total_usd", "status", "region"], inplace=True
    )

    products.drop(
        columns=[
            "region",
            "investment_rounds",
            "invested_companies",
            "funding_rounds",
            "funding_total_usd",
            "relationships",
        ],
        inplace=True,
    )

    financial_orgs.drop(
        columns=["funding_rounds", "funding_total_usd"], inplace=True
    )

    return companies, people, products, financial_orgs
