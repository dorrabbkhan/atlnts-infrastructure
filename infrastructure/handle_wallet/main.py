import bit
import time

def hello_world(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    request_json = request.get_json()
    if request_json["action"] and request_json["action"] == "generate":
        key = bit.PrivateKeyTestnet()
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



