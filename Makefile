spin-up-psql-container:
	podman run -dp 5432:5432 --rm --name psql --env POSTGRES_PASSWORD=secret postgres:latest

engage-psql-container:
	pgcli --host localhost --username postgres

