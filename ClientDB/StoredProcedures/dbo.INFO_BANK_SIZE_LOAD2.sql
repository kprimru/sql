USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[INFO_BANK_SIZE_LOAD2]
	@Data	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Xml			Xml,
		@ToDay			SmallDateTime;

	DECLARE @Ib Table
	(
		[InfoBankName]		VarChar(100)	NOT NULL,
		[InfoBankFile]		VarChar(100)	NOT NULL,
		[InfoBankFileSize]	BigInt			NOT NULL
		PRIMARY KEY CLUSTERED([InfoBankName], [InfoBankFile])
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Xml	= Cast(@Data AS Xml);
		SET @ToDay	= dbo.DateOf(GetDate());

		INSERT INTO @Ib([InfoBankName], [InfoBankFile], [InfoBankFileSize])
		SELECT
			c.value('(@Ib)[1]',		'VarChar(100)'),
			c.value('(@File)[1]',	'VarChar(100)'),
			c.value('(@Size)[1]',	'BigInt')
		FROM @xml.nodes('/root/item') AS a(c);


		INSERT INTO dbo.InfoBankFile(IBF_ID_IB, IBF_NAME)
		SELECT InfoBankID, [InfoBankFile]
		FROM @Ib						AS I
		INNER JOIN dbo.InfoBankTable	AS IB ON I.InfoBankName = IB.InfoBankName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.InfoBankFile IBF
				WHERE IBF_ID_IB = InfoBankID AND [InfoBankFile] = IBF_NAME
			)
		OPTION(RECOMPILE);

		/*
		DELETE
		FROM dbo.InfoBankSize
		WHERE EXISTS
			(
				SELECT *
				FROM @Ib						AS I
				INNER JOIN dbo.InfoBankTable	AS IB	ON I.InfoBankName = IB.InfoBankName
				INNER JOIN dbo.InfoBankFile		AS IBF	ON IBF.IBF_ID_IB = IB.InfoBankID AND IBF.IBF_NAME = I.[InfoBankFile]
				WHERE IBF_ID = IBS_ID_FILE AND IBS_SIZE = FSIZE AND IBS_DATE = @ToDay
			)
		*/

		INSERT INTO dbo.InfoBankSize(IBS_ID_FILE, IBS_DATE, IBS_SIZE)
		SELECT IBF_ID, @ToDay, [InfoBankFileSize]
		FROM @Ib						AS I
		INNER JOIN dbo.InfoBankTable	AS IB	ON I.InfoBankName = IB.InfoBankName
		INNER JOIN dbo.InfoBankFile		AS IBF	ON IBF.IBF_ID_IB = IB.InfoBankID AND IBF.IBF_NAME = I.[InfoBankFile]
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.InfoBankSize
				WHERE IBS_ID_FILE = IBF_ID
					AND IBS_DATE = @ToDay
			)
		OPTION(RECOMPILE);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INFO_BANK_SIZE_LOAD2] TO rl_info_bank_size_u;
GO
