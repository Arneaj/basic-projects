import requests

def username():
    input_username = "Arneaj"

    response = requests.get(
        f'https://api.github.com/users/{input_username}/repos'
    )

    if response.status_code == 200:
        repos = response.json() # returns list of repos
    else:
        print("fail1")
        
    commits = []

    for repo in repos:
        url = repo["commits_url"]
        commit_response = requests.get(
            url[:-6]
        )
        if commit_response.status_code == 200:
            commits.append(commit_response.json())
            #print(commits)
        else:
            print("fail2")

    output_dicts = []

    for i in range(len(repos)):
        output_dicts.append({"full_name": repos[i]["full_name"]})
        output_dicts[i]["html_url"] = repos[i]["html_url"]
        output_dicts[i]["updated_at"] = repos[i]["updated_at"]

        try: 
            output_dicts[i]["sha"] = commits[i][0]["sha"]
            output_dicts[i]["author"] = commits[i][0]["commit"]["author"]["name"]
            output_dicts[i]["message"] = commits[i][0]["commit"]["message"]
        except:
            print("fail3."+str(i))

    print( output_dicts )

username()