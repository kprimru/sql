USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Maintenance].[GLOBAL_SETTING_SAVE]
    @ORG_NAME                       NVARCHAR(256),
    @UINF                           NVARCHAR(128),
    @TENDER_PATH                    NVARCHAR(512),
    @STT_PATH                       NVARCHAR(512),
    @SERV_REPORT                    NVARCHAR(512),
    @USR_PATH                       NVARCHAR(512),
    @USR_IP_PATH                    NVARCHAR(512),
    @USR_CONTROL_PATH               NVARCHAR(512),
    @SUBHOST_NAME                   NVARCHAR(32),
    @CLAIM_PATH                     NVARCHAR(512),
    @JUR_NAME                       NVARCHAR(512),
    @JUR_EMAIL                      NVARCHAR(512),
    @CLIENT_AUTO_CLAIM              BIT,
    @RIC_ADDRESS                    NVARCHAR(512),
    @RIC_LOGIN                      NVARCHAR(512),
    @RIC_PASS                       NVARCHAR(512),
    @CONTRACT_YEAR                  NVARCHAR(512),
    @SEMINAR_MAIL_HOST              NVARCHAR(512),
    @SEMINAR_MAIL_ADDRESS           NVARCHAR(512),
    @SEMINAR_MAIL_PASS              NVARCHAR(512),
    @ONLINE_SERVICES_MAIL_HOST      NVARCHAR(512),
    @ONLINE_SERVICES_MAIL_ADDRESS   NVARCHAR(512),
    @ONLINE_SERVICES_MAIL_PASS      NVARCHAR(512),
    @ONLINE_PASSWORD_PATH           NVARCHAR(512),
    @ONLINE_PASSWORD_PASS           NVARCHAR(512),
    @CONTRACT_OLD                   BIT
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

        UPDATE Maintenance.GlobalSettings
        SET GS_VALUE = @ORG_NAME
        WHERE GS_NAME = 'ORG_NAME'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'ORG_NAME', @ORG_NAME, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @UINF
		WHERE GS_NAME = 'UINF'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'UINF', @UINF, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @TENDER_PATH
		WHERE GS_NAME = 'TENDER_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'TENDER_PATH', @TENDER_PATH, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @STT_PATH
		WHERE GS_NAME = 'STT_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'STT_PATH', @STT_PATH, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @SERV_REPORT
		WHERE GS_NAME = 'SERVICE_REPORT_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'SERVICE_REPORT_PATH', @SERV_REPORT, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @USR_PATH
		WHERE GS_NAME = 'USR_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'USR_PATH', @USR_PATH, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @USR_IP_PATH
		WHERE GS_NAME = 'USR_IP_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'USR_IP_PATH', @USR_IP_PATH, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @USR_CONTROL_PATH
		WHERE GS_NAME = 'USR_CONTROL_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'USR_CONTROL_PATH', @USR_CONTROL_PATH, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @SUBHOST_NAME
		WHERE GS_NAME = 'SUBHOST_NAME'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'SUBHOST_NAME', @SUBHOST_NAME, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @CLAIM_PATH
		WHERE GS_NAME = 'CLAIM_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'CLAIM_PATH', @CLAIM_PATH, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @JUR_NAME
		WHERE GS_NAME = 'JUR_NAME'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'JUR_NAME', @JUR_NAME, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @JUR_EMAIL
		WHERE GS_NAME = 'JUR_EMAIL'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'JUR_EMAIL', @JUR_EMAIL, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @RIC_ADDRESS
		WHERE GS_NAME = 'RIC_ADDRESS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'RIC_ADDRESS', @RIC_ADDRESS, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @RIC_LOGIN
		WHERE GS_NAME = 'RIC_LOGIN'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'RIC_LOGIN', @RIC_LOGIN, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = @RIC_PASS
		WHERE GS_NAME = 'RIC_PASS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'RIC_PASS', @RIC_PASS, ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @CLIENT_AUTO_CLAIM)
		WHERE GS_NAME = 'CLIENT_AUTO_CLAIM'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'CLIENT_AUTO_CLAIM', CONVERT(VARCHAR(500), @CLIENT_AUTO_CLAIM), ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @CONTRACT_YEAR)
		WHERE GS_NAME = 'CONTRACT_YEAR'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'CONTRACT_YEAR', CONVERT(VARCHAR(500), @CONTRACT_YEAR), ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @CONTRACT_OLD)
		WHERE GS_NAME = 'CONTRACT_OLD'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'CONTRACT_OLD', CONVERT(VARCHAR(500), @CONTRACT_OLD), ''

        UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @SEMINAR_MAIL_HOST)
		WHERE GS_NAME = 'SEMINAR_MAIL_HOST'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'SEMINAR_MAIL_HOST', CONVERT(VARCHAR(500), @SEMINAR_MAIL_HOST), ''

        UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @SEMINAR_MAIL_ADDRESS)
		WHERE GS_NAME = 'SEMINAR_MAIL_ADDRESS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'SEMINAR_MAIL_ADDRESS', CONVERT(VARCHAR(500), @SEMINAR_MAIL_ADDRESS), ''

        UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @SEMINAR_MAIL_PASS)
		WHERE GS_NAME = 'SEMINAR_MAIL_PASS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'SEMINAR_MAIL_PASS', CONVERT(VARCHAR(500), @SEMINAR_MAIL_PASS), ''

        UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @ONLINE_SERVICES_MAIL_HOST)
		WHERE GS_NAME = 'ONLINE_SERVICES_MAIL_HOST'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'ONLINE_SERVICES_MAIL_HOST', CONVERT(VARCHAR(500), @ONLINE_SERVICES_MAIL_HOST), ''

        UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @ONLINE_SERVICES_MAIL_ADDRESS)
		WHERE GS_NAME = 'ONLINE_SERVICES_MAIL_ADDRESS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'ONLINE_SERVICES_MAIL_ADDRESS', CONVERT(VARCHAR(500), @ONLINE_SERVICES_MAIL_ADDRESS), ''

        UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @ONLINE_SERVICES_MAIL_PASS)
		WHERE GS_NAME = 'ONLINE_SERVICES_MAIL_PASS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'ONLINE_SERVICES_MAIL_PASS', CONVERT(VARCHAR(500), @ONLINE_SERVICES_MAIL_PASS), ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @ONLINE_PASSWORD_PATH)
		WHERE GS_NAME = 'ONLINE_PASSWORD_PATH'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'ONLINE_PASSWORD_PATH', CONVERT(VARCHAR(500), @ONLINE_PASSWORD_PATH), ''

		UPDATE Maintenance.GlobalSettings
		SET GS_VALUE = CONVERT(VARCHAR(500), @ONLINE_PASSWORD_PASS)
		WHERE GS_NAME = 'ONLINE_PASSWORD_PASS'

		IF @@ROWCOUNT = 0
			INSERT INTO Maintenance.GlobalSettings(GS_NAME, GS_VALUE, GS_NOTE)
				SELECT 'ONLINE_PASSWORD_PASS', CONVERT(VARCHAR(500), @ONLINE_PASSWORD_PASS), ''

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[GLOBAL_SETTING_SAVE] TO rl_settings;
GO
