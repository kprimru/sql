USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  Изменение данных указанного клиента
*/

ALTER PROCEDURE [dbo].[CLIENT_EDIT] 
	@clientid INT,
	@num INT,
	@psedo VARCHAR(100),  
	@clientfullname VARCHAR(250),
	@clientshortname VARCHAR(150),  
	@clientfounding VARCHAR(300),
	@clientemail VARCHAR(100),  
	@clientinn VARCHAR(50),
	@clientkpp VARCHAR(50),
	@clientokpo VARCHAR(50),
	@clientokonx VARCHAR(50),
	@clientaccount VARCHAR(50),  
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
	@cl_1c VARCHAR(50) = NULL,
	@org_calc SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.ClientTable 
		SET CL_NUM = @num,
			CL_PSEDO = @psedo,   
			CL_FULL_NAME = @clientfullname, 
			CL_SHORT_NAME = @clientshortname,  
			CL_FOUNDING = @clientfounding, 
			CL_EMAIL = @clientemail,   
			CL_INN = @clientinn, 
			CL_KPP = @clientkpp, 
			CL_OKPO = @clientokpo, 
			CL_OKONX = @clientokonx, 
			CL_ACCOUNT = @clientaccount,   
			CL_ID_BANK = @bankid, 
			CL_ID_ACTIVITY = @activityid, 
			CL_ID_FIN = @financingid, 
			CL_ID_ORG = @organizationid, 
			CL_ID_SUBHOST = @subhostid,
			CL_ID_TYPE = @type,
			CL_NOTE = @clientnote1, 
			CL_NOTE2 = @clientnote2,
			CL_PHONE = @phone,
			CL_ID_PAYER = @payer,
			CL_1C = ISNULL(@cl_1c, CL_1C),
			CL_ID_ORG_CALC = @org_calc
		WHERE CL_ID = @clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_EDIT] TO rl_client_w;
GO