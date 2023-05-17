import asyncio
import requests
import json


def construct_data_for_prometheus(data):
    def construct_for_field(field, type, help, value):
        if field in data:
            return f"# TYPE {field} {type}\n# HELP {field} {help}\n{field} {value}\n"
        return ""

    s = ""
    s += construct_for_field(
        "manual_memory_avail_bytes",
        "gauge",
        "RAM bytes available.",
        data["manual_memory_avail_bytes"],
    )
    s += construct_for_field(
        "manual_uptime",
        "gauge",
        "RAM bytes available.",
        data["manual_uptime"],
    )
    return s


def json_from_everything(everything):
    s = everything.decode().replace("'", '"')
    s = s.replace("\t", "")
    s = s.replace("\n", "")
    s = s.replace(",}", "}")
    s = s.replace(",]", "]")
    return json.loads(s)


def http_importer(ip):
    # Netis n4 (https://4pda.to/forum/index.php?showtopic=1031030&st=40)
    # RAM: 64Mb
    resp = requests.get(
        f"http://{ip}/cgi-bin/skk_get.cgi",
        auth=requests.auth.HTTPDigestAuth("guest", "!watr00shka4ever"),
    )
    j = json_from_everything(resp.content)
    return {
        "manual_memory_avail_bytes": 64
        * 1024
        * 1024
        * (100 - int(j["mem"][:-1]))
        / 100,
        "manual_uptime": j["system_uptime"],
    }


async def minutely():
    while True:
        d = construct_data_for_prometheus(http_importer("192.168.1.254"))
        url = "http://192.168.1.19/pushgateway/metrics/job/manual/instance/netis-n4"
        try:
            r = requests.post(url, data=d)
        except:
            pass
        print(r.status_code, r.text)
        await asyncio.sleep(60)


def stop():
    task.cancel()


loop = asyncio.get_event_loop()
task = loop.create_task(minutely())

try:
    loop.run_until_complete(task)
except asyncio.CancelledError:
    pass
