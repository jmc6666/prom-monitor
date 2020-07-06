from flask import Flask, request
import json
import re, datetime
import dingtalkchatbot.chatbot as cb
import logging
import os

"""
Version: 1.0
Author: jiangran
Dept: opt
Create Time: 2020-06-23
Description: 本脚本封装了钉钉报警接口,单矿版
Support: 公司服务器，现场矿

"""

app = Flask(__name__)

logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

env_dist = os.environ

# 获取环境变量
OPTS = json.loads(env_dist['OPTS'])
TOKEN = env_dist['TOKEN']

# 钉钉报警
def ding_alert(alert_data, ding_token, at_mobiles):
        try:
            alerts = alert_data['alerts']
            for alert in alerts:
                title = "%s: %s" % (alert['labels']['env'], alert['labels']['alertname'])
                text_firing = "#### 通知: %s <font color=#FF0000>(状态：%s)</font>\n" % (alert['labels']['alertname'], alert['status'])
                text_reslove = "#### 通知: %s <font color=#008000>(状态：%s)</font>\n" % (alert['labels']['alertname'], alert['status'])
                xiaoding = cb.DingtalkChatbot(ding_token)
                if alert['status'] == 'firing':
                    res = xiaoding.send_markdown(title, text_firing, at_mobiles=at_mobiles)
                    logger.info(res)
                else:
                    xiaoding.send_markdown(title, text_reslove, at_mobiles=at_mobiles)
        except Exception as e:
            print(e)
        return "ok"

# 报警接口
@app.route('/send/pro', methods=['POST'])
def send_pro():
    alert_data = json.loads(request.data)
    ding_token = "https://oapi.dingtalk.com/robot/send?access_token=87094990480806233be942b43678b1c519871c56d2e841bd9a12994479ff272d"
    status = ding_alert(alert_data, ding_token, [15011183251])
    return status

@app.route('/send/test', methods=['POST'])
def send_test():
    alert_data = json.loads(request.data)
    ding_token = TOKEN
    at_mobiles = []
    # 通知对象
    for phone in OPTS.values():
        at_mobiles.append(phone)
    status = ding_alert(alert_data, ding_token, at_mobiles)
    return status

# 主程序
if __name__ == '__main__':
    app.run(
      host = '0.0.0.0',
      port = 5000,
      debug = True
    )
