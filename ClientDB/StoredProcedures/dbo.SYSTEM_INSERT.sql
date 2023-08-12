USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_INSERT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SYSTEM_INSERT]
	@SHORT	VARCHAR(20),
	@NAME	VARCHAR(200),
	@BASE	VARCHAR(50),
	@NUMBER	INT,
	@HOST	INT,
	@RIC	INT,
	@ORDER	INT,
	@VMI	INT,
	@FULL	VARCHAR(250),
	@ACTIVE	BIT,
	@DEMO	BIT,
	@COMPLECT	BIT,
	@REG	BIT,
	@BASE_CHECK	BIT,
	@IB_REQ	VARCHAR(MAX),
	@IB		VARCHAR(MAX),
	@WEIGHT	DECIMAL(8,4),
	@ID	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF EXISTS
			(
				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

				INTERSECT

				SELECT Item
				FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')
			)
		BEGIN
			DECLARE @BN	VARCHAR(MAX)

			SELECT @BN = InfoBankShortName + ', '
			FROM
				dbo.InfoBankTable
				INNER JOIN
					(
						SELECT Item
						FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

						INTERSECT

						SELECT Item
						FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')
					) AS o_O ON InfoBankID = Item
			ORDER BY InfoBankShortName

			SET @BN = LEFT(@BN, LEN(@BN) - 1)

			SET @BN = 'ИБ указаны как обязательные и как необязательные' + @BN

			RAISERROR (@BN, 16, 1)

			RETURN
		END

		INSERT INTO dbo.SystemTable(
				SystemShortName, SystemName, SystemBaseName, SystemNumber,
				HostID, SystemRic, SystemOrder, SystemVMI, SystemFullName, SystemActive,
				SystemDemo, SystemComplect, SystemReg, SystemBaseCheck, SystemSalaryWeight)
			VALUES(@SHORT, @NAME, @BASE, @NUMBER, @HOST, @RIC, @ORDER, @VMI, @FULL, @ACTIVE, @DEMO, @COMPLECT, @REG, @BASE_CHECK, @WEIGHT)

		SELECT @ID = SCOPE_IDENTITY()


		INSERT INTO dbo.SystemBankTable(SystemID, InfoBankID, Required)
			SELECT @ID, Item, 0
			FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

		INSERT INTO dbo.SystemBankTable(SystemID, InfoBankID, Required)
			SELECT @ID, Item, 1
			FROM dbo.GET_TABLE_FROM_LIST(@IB_REQ, ',')


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_INSERT] TO rl_system_i;
GO
