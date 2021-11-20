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
    if request_json and 'from' in request_json and 'to' in request_json and 'amount' in request_json:
        from_wif = request_json['from']
        to_addr = request_json['to']
        amount_usd = request_json['amount']

        my_key = bit.PrivateKeyTestnet(from_wif)
        balance_before = my_key.balance_as('usd')
        tx_hash = my_key.send([(
            to_addr,
            float(amount_usd),
            'usd'
        )])
        time.sleep(1)
        balance_after = my_key.balance_as('usd')
        return {
            "before": balance_before,
            "after": balance_after,
            "tx_hash": tx_hash,
            "success": True
        }, 200
    else:
        return "Invalid request", 400
