import os
import argparse
import requests
import json
from jira import JIRA

# Parsing command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('-c', '--component', type=str, required=True)
parser.add_argument('-v', '--version', type=str, required=True)
args = parser.parse_args()
release = args.component + ':' + args.version

# Connecting to Jira
host = os.environ['JIRA_URL']
user = os.environ['JIRA_USER']
password = os.environ['JIRA_PASSWORD']
jira_options = {'server': host}
jira = JIRA(options=jira_options, basic_auth=(user, password))

# Loading issues
jql = f'fixVersion = "{release}"'
issues = jira.search_issues(jql, maxResults=0, fields='summary,labels,issuetype')

# Converting issues
sub_bugs={
    'title':'SUB-BUGS',
    'color':'#f74e09',
    'text':''
}
bugs={
    'title':'BUGS',
    'color':'#f74e09',
    'text':''
}
tasks={
    'title':'TASKS',
    'color':'#2a95ca',
    'text':''
}
sub_tasks={
    'title':'SUB-TASKS',
    'color':'#2a95ca',
    'text':''
}
user_stories={
    'title':'USER STORIES',
    'color':'#46ae3d',
    'text':''
}

for issue in issues:
    if issue.fields.issuetype.name=='Sub-Bug':
        sub_bugs['text']+=f"• *<{host+'/browse/'+issue.key}|{issue.key}>* - {issue.fields.summary} (Labels: {issue.fields.labels})\n"
    elif issue.fields.issuetype.name == 'Bug':
        bugs['text']+=f"• *<{host+'/browse/'+issue.key}|{issue.key}>* - {issue.fields.summary} (Labels: {issue.fields.labels})\n"
    elif issue.fields.issuetype.name=='Sub-task':
        sub_tasks['text']+=f"• *<{host+'/browse/'+issue.key}|{issue.key}>* - {issue.fields.summary} (Labels: {issue.fields.labels})\n"
    elif issue.fields.issuetype.name=='Task':
        tasks['text']+=f"• *<{host+'/browse/'+issue.key}|{issue.key}>* - {issue.fields.summary} (Labels: {issue.fields.labels})\n"
    elif issue.fields.issuetype.name=='User Story':
        user_stories['text']+=f"• *<{host+'/browse/'+issue.key}|{issue.key}>* - {issue.fields.summary} (Labels: {issue.fields.labels})\n"

# prepare message
message_header = f':bell: *{release}* _Released_'
message_body = []

for type in (bugs,user_stories,sub_bugs,sub_tasks,tasks):
    if type['text']!='':
        message_body.append(type)

message = {
    "text": message_header,
    "attachments":message_body
}

# Connect to Slack
url = os.environ['RELEASE_SLACK_HOOK_URL']
response = requests.post(url, json=message)
