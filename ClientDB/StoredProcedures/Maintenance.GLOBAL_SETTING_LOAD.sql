USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GLOBAL_SETTING_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[GLOBAL_SETTING_LOAD]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[GLOBAL_SETTING_LOAD]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SELECT
            [CONTROL_LOGIN] = Cast([Maintenance].[GlobalSetting@Get]('CONTROL_LOGIN') AS Bit),
			[BCP]	= Cast([Maintenance].[GlobalSetting@Get]('BCP') AS VarChar(256)),
			[BCP_EX]	= Cast([Maintenance].[GlobalSetting@Get]('BCP_EX') AS VarChar(256)),
			[UINF_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('UINF_PATH') AS VarChar(256)),

			[ORG_NAME]		= Cast([Maintenance].[GlobalSetting@Get]('ORG_NAME') AS VarChar(256)),
            [UINF]			= Cast([Maintenance].[GlobalSetting@Get]('UINF') AS VarChar(256)),
			[TENDER_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('TENDER_PATH') AS VarChar(256)),

			[STT_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('STT_PATH') AS VarChar(256)),
			[SERV_REPORT]	= Cast([Maintenance].[GlobalSetting@Get]('SERVICE_REPORT_PATH') AS VarChar(256)),
			[USR_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('USR_PATH') AS VarChar(256)),
			[USR_IP_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('USR_IP_PATH') AS VarChar(256)),
			[USR_CONTROL_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('USR_CONTROL_PATH') AS VarChar(256)),

            [SUBHOST_NAME]		= Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128)),

			[CLAIM_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('CLAIM_PATH') AS VarChar(256)),
			[JUR_NAME]	= Cast([Maintenance].[GlobalSetting@Get]('JUR_NAME') AS VarChar(256)),
			[JUR_EMAIL]	= Cast([Maintenance].[GlobalSetting@Get]('JUR_EMAIL') AS VarChar(256)),
			[RIC_ADDRESS]	= Cast([Maintenance].[GlobalSetting@Get]('RIC_ADDRESS') AS VarChar(256)),
			[RIC_LOGIN]	= Cast([Maintenance].[GlobalSetting@Get]('RIC_LOGIN') AS VarChar(256)),
			[RIC_PASSWORD]	= Cast([Maintenance].[GlobalSetting@Get]('RIC_PASSWORD') AS VarChar(256)),
			[CLIENT_AUTO_CLAIM]	= Cast([Maintenance].[GlobalSetting@Get]('CLIENT_AUTO_CLAIM') AS Bit),
			[CLIENT_AUTO_CLAIM_TYPES]	= Cast([Maintenance].[GlobalSetting@Get]('CLIENT_AUTO_CLAIM_TYPES') AS VarChar(256)),

            [CONTRACT_YEAR]	= Cast([Maintenance].[GlobalSetting@Get]('CONTRACT_YEAR') AS UniqueIdentifier),

            [CONTRACT_OLD] = Cast([System].[Setting@Get]('CONTRACT_OLD') AS Bit),

			[CONTROL_DOCUMENT_URL]	= Cast([Maintenance].[GlobalSetting@Get]('CONTROL_DOCUMENT_URL') AS VarChar(256)),
			[CONTROL_DOCUMENT_USER]	= Cast([Maintenance].[GlobalSetting@Get]('CONTROL_DOCUMENT_USER') AS VarChar(256)),
			[CONTROL_DOCUMENT_PASS]	= Cast([Maintenance].[GlobalSetting@Get]('CONTROL_DOCUMENT_PASS') AS VarChar(256)),

			[SEMINAR_MAIL_HOST]	= Cast([Maintenance].[GlobalSetting@Get]('SEMINAR_MAIL_HOST') AS VarChar(256)),
			[SEMINAR_MAIL_ADDRESS]	= Cast([Maintenance].[GlobalSetting@Get]('SEMINAR_MAIL_ADDRESS') AS VarChar(256)),
			[SEMINAR_MAIL_PASS]	= Cast([Maintenance].[GlobalSetting@Get]('SEMINAR_MAIL_PASS') AS VarChar(256)),

			[ONLINE_SERVICES_MAIL_HOST]	= Cast([Maintenance].[GlobalSetting@Get]('ONLINE_SERVICES_MAIL_HOST') AS VarChar(256)),
			[ONLINE_SERVICES_MAIL_ADDRESS]	= Cast([Maintenance].[GlobalSetting@Get]('ONLINE_SERVICES_MAIL_ADDRESS') AS VarChar(256)),
			[ONLINE_SERVICES_MAIL_PASS]	= Cast([Maintenance].[GlobalSetting@Get]('ONLINE_SERVICES_MAIL_PASS') AS VarChar(256)),

			[ONLINE_PASSWORD_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('ONLINE_PASSWORD_PATH') AS VarChar(256)),
			[ONLINE_PASSWORD_PASS]	= Cast([Maintenance].[GlobalSetting@Get]('ONLINE_PASSWORD_PASS') AS VarChar(256)),

			[REPOSITORY_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('REPOSITORY_PATH') AS VarChar(256)),

			[PROTOCOL_PATH] = Cast([Maintenance].[GlobalSetting@Get]('PROTOCOL_PATH') AS VarChar(256)),
			[CONFIG_PATH]	= Cast([Maintenance].[GlobalSetting@Get]('CONFIG_PATH') AS VarChar(256)),

			Convert(smalldatetime, (SELECT G.[GS_VALUE] FROM [Maintenance].[GlobalSettings] AS G WHERE G.[GS_NAME] = 'CLIENT_DUTY_DATE'), 104) AS CLIENT_DUTY_DATE

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[GLOBAL_SETTING_LOAD] TO public;
GRANT EXECUTE ON [Maintenance].[GLOBAL_SETTING_LOAD] TO rl_settings;
GO
