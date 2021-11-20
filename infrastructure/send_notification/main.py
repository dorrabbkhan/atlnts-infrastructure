from twilio.rest import Client
from trycourier import Courier
import os

def hello_world(request):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    twilio_sid = os.environ['TWILIO_SID']
    twilio_auth_token = os.environ['TWILIO_AUTH_TOKEN']
    twilio_msg_sid = os.environ['TWILIO_MSG_SID']
    email_auth_token = os.environ['EMAIL_AUTH_TOKEN']
    email_event = os.environ['EMAIL_EVENT']
    email_recipient = os.environ['EMAIL_RECIPIENT']
    email_brand = os.environ['EMAIL_BRAND']

    request_json = request.get_json()
    if request_json and 'name' in request_json and 'phone' in request_json and 'email' in request_json and \
        request_json['finder_name'] and request_json['finder_phone'] and request_json['finder_email'] and \
            request_json['item'] and request_json['amount']:

        client = Client(twilio_sid, twilio_auth_token) 
        email_client = Courier(auth_token=email_auth_token)

        resp = email_client.send(
        event=email_event,
        recipient=email_recipient,
        brand=email_brand,
        profile={
            "email": request_json['email'],
        },
        data={
            "name": request_json['name'],
            "item": request_json['item'],
            "amount": request_json['amount'],
            "finder_name": request_json['finder_name'],
            "finder_email": request_json['finder_email'],
            "finder_phone": request_json['finder_phone'],
        },
        )

        message = client.messages.create(  
                                    messaging_service_sid=twilio_msg_sid, 
                                    body=f"Hello {request_json['name']}, your item {request_json['item']} has been found. Contact your finder here: \n{request_json['finder_name']}\n{request_json['finder_email']}\n{request_json['finder_phone']}",      
                                    to=request_json['phone'] 
                                ) 
        
        return {
            "email_id": resp['messageId'],
            "sms_id": message.sid,
            "success": True
        }, 200

    else:
        return "Invalid request", 400


