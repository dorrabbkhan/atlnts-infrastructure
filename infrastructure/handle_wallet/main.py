import bit
import sqlalchemy

def hello_world(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    request_json = request if isinstance(request, dict) else request.get_json()
    if request_json["action"] and request_json["action"] == "generate" and request_json["email"]:
        key = bit.PrivateKeyTestnet()

        pool = sqlalchemy.create_engine(
            "mysql+pymysql://root:plschangeme@34.159.117.11:3306/lighthouse"
        )

        with pool.connect() as conn:
            try:
                conn.execute("CREATE TABLE IF NOT EXISTS credentials (email VARCHAR(255) NOT NULL, secret VARCHAR(255) NOT NULL, wallet VARCHAR(255) NOT NULL, PRIMARY KEY (email))")
                conn.execute(f"INSERT INTO credentials (email, secret, wallet) VALUES (\"{request_json['email']}\", \"{key.to_wif()}\", \"{key.address}\")")
            except Exception as e:
                return f"Error inserting data into the database: {e}", 500

        return {
            "version": key.version,
            "wif": key.to_wif(),
            "address": key.address
        }, 200

    elif request_json["action"] and request_json["wif"] and \
        request_json["action"] == "status" and request_json["wif"]:
        key = bit.PrivateKeyTestnet(request_json["wif"])
        
        return {
            "balance": key.balance,
            "balance_usd": key.balance_as('usd'),
            "wif": key.to_wif(),
            "address": key.address,
            "version": key.version
        }, 200
    else: return "Invalid request", 400


if __name__ == "__main__":
    hello_world({
        "action": "generate",
        "email": "dorrabbk@gmail.com"
    })
