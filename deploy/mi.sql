CREATE USER $(accountName) FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER $(accountName);
ALTER ROLE db_datawriter ADD MEMBER $(accountName);
ALTER ROLE db_ddladmin ADD MEMBER $(accountName);
GO