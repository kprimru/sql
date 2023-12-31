USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_DEFAULT]
	@client INT
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

		DECLARE @CO_BEGIN	SMALLDATETIME
		DECLARE @CO_END		SMALLDATETIME
		DECLARE @CTT_ID		SMALLINT
		DECLARE	@CTT_NAME	VARCHAR(100)
		DECLARE @COP_ID		SMALLINT
		DECLARE @COP_NAME	VARCHAR(100)
		DECLARE	@CK_ID		SMALLINT
		DECLARE @CK_NAME	VARCHAR(100)
		DECLARE @CO_IDENT	NVARCHAR(128)

		SELECT TOP 1
			@CTT_ID = CTT_ID, @CTT_NAME = CTT_NAME,
			@COP_ID = COP_ID, @COP_NAME = COP_NAME,
			@CK_ID = CK_ID, @CK_NAME = CK_NAME,
			@CO_BEGIN = CO_BEG_DATE, @CO_END = CO_END_DATE,
			@CO_IDENT = CO_IDENT
		FROM
			dbo.ContractTable co LEFT OUTER JOIN
			dbo.ContractTypeTable ctt ON ctt.CTT_ID = co.CO_ID_TYPE LEFT OUTER JOIN
			dbo.ContractPayTable ON COP_ID = CO_ID_PAY LEFT OUTER JOIN
			dbo.ContractKind ON CK_ID = CO_ID_KIND
		WHERE CO_ID_CLIENT = @client
		ORDER BY CO_ACTIVE DESC, CO_DATE DESC

		SELECT
			@CTT_ID AS CTT_ID, @CTT_NAME AS CTT_NAME,
			@COP_ID AS COP_ID, @COP_NAME AS COP_NAME,
			@CK_ID AS CK_ID, @CK_NAME AS CK_NAME,
			DATEADD(DAY, 1, @CO_END) AS CO_BEG_DATE,
			DATEADD(
				MONTH,
				CASE
					WHEN DATEDIFF(MONTH, DATEADD(DAY, -1, @CO_BEGIN), @CO_END) > 12 THEN 12
					ELSE DATEDIFF(MONTH, DATEADD(DAY, -1, @CO_BEGIN), @CO_END)
				END,
				@CO_END) AS CO_END_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_DEFAULT] TO rl_client_contract_r;
GO
