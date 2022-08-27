docker run --rm --name voodDB \
-p 1234:1521 \
-p 5678:5500 \
-e ORACLE_PWD=1 \
-e ORACLE_SID=orcl \
-e ORACLE_PDB=pdb \
--shm-size="4g" \
oracle/database:19.3.0-ee


docker run --name voodDB \
-p 1234:1521 \
-p 5678:5500 \
-e ORACLE_PWD=1 \
-e ORACLE_SID=orcl \
-e ORACLE_PDB=pdb \
--shm-size="4g" \
oracle/database:19.3.0-ee

docker exec -ti oracle sqlplus / as sysdba
alter pluggable database pdb1 open;



./buildContainerImage.sh -e -v 19.3.0 -o '--build-arg SLIMMING=false'


docker rmi $(docker images -q)
