import sqlalchemy
import requests

def hello_world(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    request_uuid = request.get('uuid')
    if request_uuid:

        pool = sqlalchemy.create_engine(
            "mysql+pymysql://root:plschangeme@34.159.117.11:3306/lighthouse"
        )

        with pool.connect() as conn:
            try:
                result = conn.execute(f"SELECT from_secret, to_wallet, amount FROM transactions WHERE id=\"{request_uuid}\"").all()[0]
                from_secret, to_wallet, amount = result[0], result[1], result[2]
                payload = {
                    "from": from_secret,
                    "to": to_wallet,
                    "amount": amount
                }

                headers = {
                    'Content-type': 'application/json',
                }
                response = requests.post("https://europe-west3-nifty-saga-332620.cloudfunctions.net/btc_transfers", headers=headers, json=payload)
                if response.status_code != 200:
                    return f"Error making transaction", 500
                return 200
                
            except Exception as e:
                return f"Error making transaction: {e}", 500




if __name__ == "__main__":
    hello_world({
        "uuid": "34d39541-4a65-11ec-90f8-42010a9c0002"
    })
