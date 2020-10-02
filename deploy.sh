tag=$(get_octopusvariable "Project.Duck.ServerTag")

echo "Stop duck-local."
systemctl is-active --quiet jenkins-local && systemctl stop jenkins-local

docker-compose down

if [ ! -d "data" ]; then
    echo "Create data folder."
    mkdir data
fi

docker-compose pull
docker-compose up -d

mv duck.json data/
mv duck-local.service /etc/systemd/system
mv duck.local /etc/nginx/sites-available

if [ ! -e "/etc/nginx/sites-enabled/duck.local" ]; then
    echo "Create /etc/nginx/sites-enabled/duck.local."
    ln -s /etc/nginx/sites-available/duck.local /etc/nginx/sites-enabled/duck.local
fi

echo "Start duck-local."
systemctl is-enabled --quiet duck-local || systemctl enable duck-local
systemctl start duck-local
echo "Reload systemctl daemon."
systemctl daemon-reload
echo "Restart nginx."
systemctl restart nginx

write_highlight "[duck.local](https://duck.local)"

exit 0
