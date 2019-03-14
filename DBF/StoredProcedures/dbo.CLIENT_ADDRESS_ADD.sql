USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	



/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_ADD] 
	@clientid INT,
	@streetid INT,
	@index VARCHAR(100),
	@home VARCHAR(100),
	@addresstypeid INT,
	@addressstr VARCHAR(500),
	@templateid SMALLINT = null,
	@free VARCHAR(500) = null,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ClientAddressTable
						(
							CA_ID_CLIENT, CA_ID_TYPE, CA_ID_STREET, 
							CA_HOME, CA_INDEX, CA_STR, CA_ID_TEMPLATE, CA_FREE
						) 
	VALUES (@clientid, @addresstypeid, @streetid, @home, @index, @addressstr, @templateid, @free)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	IF @templateid IS NOT NULL
		INSERT INTO dbo.ClientFinancingAddressTable(CFA_ID_CLIENT, CFA_ID_FAT, CFA_ID_ATL)
		SELECT @clientid, FAT_ID, @templateid
		FROM dbo.FinancingAddressTypeTable
		WHERE ISNULL(FAT_ID_ADDR_TYPE, @addresstypeid) = @addresstypeid
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientFinancingAddressTable
					WHERE CFA_ID_CLIENT = @clientid
						AND CFA_ID_FAT = FAT_ID
				)


	SET NOCOUNT OFF
END








