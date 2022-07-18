let html_entry_container;
let pulls = [];
let requests_open = 0;
let assembled_info = [];

let token = "";

/* called by <body> on load
*/
function init() {
    html_entry_container = document.getElementById("entrys");
    refresh();
}

/* called by <button> 'Authenticate' on click
*/
function token_authentication() {
    input_token = document.getElementById("input_auth_token");
    if (input_token !== null) {
        token = input_token.value;
        input_token.value = "";
    }
    refresh({ "clear_cache": true });
}

/* called by <button> 'Continue without Token' on click
** called by <button> 'Reload' on click
*/
function refresh(params) {
    html_entry_container.innerHTML = "";
    let dialog = document.getElementById("token_dialog");
    dialog.classList.add("hide");
    requests_open = 0;
    fetch_api('https://api.github.com/repos/letsgamedev/Suffragium/pulls', callback_api_pulls, params);
}

function fetch_api(url, callback, params) {
    let res;
    let headers = new Headers();
    if (token != "") {
        headers.append("Authorization", "token " + token);
    }
    let init = {
        method: "GET",
        headers: headers
    };
    if (params && params.clear_cache) {
        init.cache = "reload";
    }
    fetch(url, init)
        .then(response => {
            res = response;
            if (response.ok) {
                return response.json();
            } else {
                console.log("NOT SUCCESSFUL");
                open_auth_token_dialog("ERROR " + response.status + " Unauthorized (Invalid Token)");
            }
        })
        .then(data => {
            callback(data, params, res);
        });
    requests_open += 1;
}

function callback_api_pulls(data, params, res) {
    if (!data) {
        open_auth_token_dialog();
        return;
    }
    pulls = data;
    console.log('x-ratelimit-remaining: ', res.headers.get('x-ratelimit-remaining'));
    console.log('need to fetch info for ' + pulls.length + ' pull requests (' + pulls.length * 2 + ' requests)');

    if (pulls && res.headers.get('x-ratelimit-remaining') < pulls.length * 2) {
        open_auth_token_dialog();
        return;
    }
    for (i = 0; i < pulls.length; i++) {
        let pull = pulls[i];
        fetch_api(pull.issue_url, callback_api_pull_issue, { index: i });
        fetch_api(pull.commits_url, callback_api_pull_commits, { index: i });
    }
    callback_finished();
}

function open_auth_token_dialog(msg) {
    let dialog = document.getElementById("token_dialog");
    let dialog_msg = document.getElementById("token_dialog_msg");
    if (msg) {
        dialog_msg.innerHTML = msg;
        dialog.classList.remove("hide");
    } else
        dialog.classList.add("hide");
    dialog.classList.remove("hide");
}

function callback_api_pull_issue(data, params, res) {
    let pull_issue = data;
    let index = params.index;
    pulls[index].issue_data = pull_issue;
    callback_finished();
}

function callback_api_pull_commits(data, params, res) {
    let pull_commits = data;
    let index = params.index;
    pulls[index].commits_data = pull_commits;
    callback_finished();
}

function callback_finished() {
    requests_open -= 1;
    if (requests_open === 0) {
        assemble_info();
    }
}

function assemble_info() {
    let info = [];
    for (i = 0; i < pulls.length; i++) {
        let pull = pulls[i];
        let reactions = pull.issue_data.reactions;
        let commits_data = pull.commits_data;
        info[i] = {};
        info[i].title = pull.title;
        info[i].draft = pull.draft;
        info[i].votes = { '+1': reactions['+1'], '-1': reactions['-1'] };
        info[i].last_commit_time = commits_data[commits_data.length - 1].commit.committer.date;
        info[i].url = pull.html_url;
    }

    //add mockup_entrys
    /*
    info.push(mockup_entry("mockup active", false, [0, 0], "2022-06-30T16:37:44Z", "https://github.com/letsgamedev/Suffragium/"));
    info.push(mockup_entry("mockup inactive", false, [0, 0], "2022-03-30T16:37:44Z", "https://github.com/letsgamedev/Suffragium/"));
    info.push(mockup_entry("mockup has votes", false, [10, 0], "2022-03-30T16:37:44Z", "https://github.com/letsgamedev/Suffragium/"));
    info.push(mockup_entry("mockup draft active", true, [0, 0], "2022-06-30T16:37:44Z", "https://github.com/letsgamedev/Suffragium/"));
    info.push(mockup_entry("mockup draft inactive", true, [0, 0], "2022-03-30T16:37:44Z", "https://github.com/letsgamedev/Suffragium/"));
    info.push(mockup_entry("mockup draft has votes", true, [10, 0], "2022-03-30T16:37:44Z", "https://github.com/letsgamedev/Suffragium/"));
    */

    console.log(info);
    assembled_info = info;
    display_pull_entries();
}

function mockup_entry(title, draft, votes, last_commit_time, url) {
    let entry = {};
    entry.title = title;
    entry.draft = draft;
    entry.votes = { '+1': votes[0], '-1': votes[1] };
    entry.last_commit_time = last_commit_time;
    entry.url = url;
    return entry;
}

function display_pull_entries() {
    for (i = 0; i < assembled_info.length; i++) {
        let pull = assembled_info[i];
        display_pull(pull);
    }
}

function display_pull(pull) {
    let days_since_last_commit = get_days_since_last_commit(pull);
    let votes_up = pull.votes['+1'];
    let votes_down = pull.votes['-1'];
    let vote_count = votes_up + votes_down;
    let percentage = Math.round(votes_up / vote_count * 1000) / 10;

    let status_class = get_status_class(pull.draft, votes_up, votes_down, days_since_last_commit);
    let html_draft_class = "";
    let html_draft_title = "";
    if (pull.draft) {
        html_draft_class = " pr_draft";
        html_draft_title = "Draft: ";
    }
    let html_vote_percent = "";
    if (!isNaN(percentage)) {
        html_vote_percent = ' (' + percentage + '%) ';
    }

    let html_a_open = '<a href="' + pull.url + '" target="_blank">';
    let html_outer_open = '<div class="pr_outer_box' + status_class + '">';
    let html_inner_open = '<div class="pr_box' + html_draft_class + '">';
    let html_title = '<h3>' + html_draft_title + pull.title + '</h3>';
    let html_votes = '<span>👍 ' + pull.votes['+1'] + ' 👎 ' + pull.votes['-1'] + html_vote_percent + '</span>';
    let html_last_commit = '<span>last commit: ' + days_since_last_commit + ' days ago</span>';
    let html_close = '</div></div></a>';
    let html = html_a_open + html_outer_open + html_inner_open + html_title + html_votes + html_last_commit + html_close;
    html_entry_container.innerHTML += html;
}

function get_days_since_last_commit(pull_info) {
    let last_commit_unix_ms = Date.parse(pull_info.last_commit_time);
    let time_now_unix_ms = Date.now();
    let time_span_ms = time_now_unix_ms - last_commit_unix_ms;
    return Math.round(time_span_ms / 864000) / 100;
}

function get_status_class(is_draft, votes_up, votes_down, last_commit_days) {
    let vote_count = votes_up + votes_down;
    let positive_votes = votes_up / vote_count;
    if (!is_draft) {
        if (last_commit_days >= 1 && vote_count > 10 && positive_votes >= 0.75) {
            return " status_merge";
        }
        if (last_commit_days >= 3 && positive_votes >= 0.75) {
            return " status_merge";
        }
    }

    if (last_commit_days >= 20) {
        return " status_delete";
    }
    return "";
}
