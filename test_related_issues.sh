#!/bin/bash

echo "User based"
export MOVE_RELATED_ISSUES="true"
./entrypoint.sh user status leonsteinhaeuser 5 PR_kwDOGWypss5KPRmJ Todo
./entrypoint.sh user status leonsteinhaeuser 5 PR_kwDOGWypss5KPRmJ Done

echo "Organisation based"
export MOVE_RELATED_ISSUES="true"
./entrypoint.sh "organization" "status" "${MY_ORG}" "1" "PR_kwDOGoqhi85KS6Ox" "Todo"
./entrypoint.sh "organization" "status" "${MY_ORG}" "1" "PR_kwDOGoqhi85KS6Ox" "Done"
