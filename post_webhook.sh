curl --location --request POST 'http://localhost:5000/webhooks' \
--header 'Content-Type: application/json' \
--data-raw '{
    "merchant_id": "6SSW7HV8K2ST5",
    "type": "payment.updated",
    "event_id": "04e83593-ad20-4adf-8e7e-bd05f4a04e53",
    "created_at": "2020-04-25T21:07:56.961989279Z",
    "data": {
        "type": "payment",
        "id": "JkAkicNrgyn48RL9B99XhKxdlxLZY",
        "object": {
            "payment": {
                "id": "JkAkicNrgyn48RL9B99XhKxdlxLZY",
                "created_at": "2020-02-06T21:27:30.444Z",
                "updated_at": "2020-02-06T21:27:33.399Z",
                "amount_money": {
                    "amount": 1000,
                    "currency": "USD"
                },
                "total_money": {
                    "amount": 1000,
                    "currency": "USD"
                },
                "status": "COMPLETED",
                "source_type": "CARD",
                "card_details": {
                    "auth_result_code": "YFB91d",
                    "avs_status": "AVS_ACCEPTED",
                    "card": {
                        "bin": "411111",
                        "card_brand": "VISA",
                        "card_type": "CREDIT",
                        "exp_month": 2,
                        "exp_year": 2022,
                        "fingerprint": "sq-1-pu54rLMT5m8qddqnsWaSBI9zJkDH_mMy8hC2qe6MUzdP4MCSHaHZtm_XNuiiso95gQ",
                        "last_4": "1111"
                    },
                    "cvv_status": "CVV_ACCEPTED",
                    "entry_method": "KEYED",
                    "statement_description": "SQ *MY BUSINESS",
                    "status": "CAPTURED"
                },
                "location_id": "NAQ1FHV6ZJ8YV",
                "order_id": "j3WfFVLi7XdcrH3BxoV0L3EHqe4F",
                "receipt_number": "JkAk",
                "receipt_url": "https://squareup.com/receipt/preview/JkAkicNrgyn48RL9B99XhKxdlxLZY",
                "reference_id": "123456",
                "note": "Brief description",
                "customer_id": "VDKXEEKPJN48QDG3BGGFAK05P8",
                "version": 4
            }
        }
    }
}'
