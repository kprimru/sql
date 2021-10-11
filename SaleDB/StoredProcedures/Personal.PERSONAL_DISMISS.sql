USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_DISMISS]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@NEW_ID	UNIQUEIDENTIFIER = NULL OUTPUT
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
		DECLARE @LG	NVARCHAR(128)

		SELECT @LG = LOGIN
		FROM Personal.OfficePersonal
		WHERE ID = @ID

		DECLARE @RN	BIGINT

		SELECT @RN = RN
		FROM
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM Personal.OfficePersonal
			) AS o_O
		WHERE ID = @ID

		SELECT TOP 1 @NEW_ID = ID
		FROM
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM Personal.OfficePersonal
			) AS o_O
		WHERE ID <> @ID
			AND RN IN
				(
					SELECT @RN + 1
					UNION ALL
					SELECT @RN - 1
				)

		UPDATE	Personal.OfficePersonal
		SET		END_DATE	=	@DATE
		WHERE	ID			=	@ID

		DECLARE @COMPANY NVARCHAR(MAX)

		SELECT @COMPANY =
			(
				SELECT ID AS 'item/@id'
				FROM Client.CompanyProcessSaleView
				WHERE ID_PERSONAL = @ID
				FOR XML PATH('root')
			)

		EXEC Client.COMPANY_PROCESS_SALE_RETURN @COMPANY

		SELECT @COMPANY =
			(
				SELECT ID AS 'item/@id'
				FROM Client.CompanyProcessPhoneView
				WHERE ID_PERSONAL = @ID
				FOR XML PATH('root')
			)

		EXEC Client.COMPANY_PROCESS_PHONE_RETURN @COMPANY

		SELECT @COMPANY =
			(
				SELECT ID AS 'item/@id'
				FROM Client.CompanyProcessManagerView
				WHERE ID_PERSONAL = @ID
				FOR XML PATH('root')
			)

		EXEC Client.COMPANY_PROCESS_MANAGER_RETURN @COMPANY

		EXEC Security.USER_DELETE @LG

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_DISMISS] TO rl_personal_w;
GO
