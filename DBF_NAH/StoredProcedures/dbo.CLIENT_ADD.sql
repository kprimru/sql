USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  Добавить клиента и получить ID добавленной записи
*/

ALTER PROCEDURE [dbo].[CLIENT_ADD]
	@num INT,
	@psedo VARCHAR(50),
	@fullname VARCHAR(500),
	@shortname VARCHAR(150),
	@founding VARCHAR(300),
	@email VARCHAR(150),
	@inn VARCHAR(50),
	@kpp VARCHAR(50),
	@okpo VARCHAR(50),
	@okonx VARCHAR(50),
	@account VARCHAR(50),
	@bankid SMALLINT,
	@activityid SMALLINT,
	@financingid SMALLINT,
	@organizationid SMALLINT,
	@subhostid SMALLINT,
	@clientnote1 TEXT,
	@clientnote2 TEXT,
	@phone VARCHAR(50),
	@type SMALLINT = NULL,
	@payer SMALLINT = NULL,
	@org_calc smallint = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ClientTable( CL_NUM,
							CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
							CL_EMAIL, CL_INN, CL_KPP, CL_OKPO, CL_OKONX,
							CL_ACCOUNT, CL_ID_BANK, CL_ID_ACTIVITY, CL_ID_FIN,
							CL_ID_ORG, CL_ID_SUBHOST, CL_ID_TYPE, CL_NOTE, CL_NOTE2, CL_PHONE, CL_ID_PAYER, CL_1C,
							CL_ID_ORG_CALC
							)
	VALUES( @num,
			@psedo, @fullname, @shortname, @founding, @email,
			@inn, @kpp, @okpo, @okonx, @account, @bankid,
			@activityid, @financingid, @organizationid, @subhostid, @type,
			@clientnote1, @clientnote2, @phone, @payer, @psedo, @org_calc
			)

	DECLARE @clientid INT

	SELECT @clientid = SCOPE_IDENTITY()

	EXEC dbo.CLIENT_DOCUMENT_SETTINGS_DEFAULT_SET @clientid

	EXEC dbo.CLIENT_FINANCING_CREATE @clientid

	IF @returnvalue = 1
		SELECT @clientid AS NEW_IDEN

	SET NOCOUNT OFF
END














GO
GRANT EXECUTE ON [dbo].[CLIENT_ADD] TO rl_client_w;
GO