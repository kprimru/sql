USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CONTROL_DOCUMENT_LOAD2]
	@Data	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @Documents Table
	(
		Id				Int				Identity(1,1)	NOT NULL,
		Dt				DateTime						NOT NULL,
		Complect		VarChar(100)					NOT NULL,
		DocNum			Int								NOT NULL,
		InfoBank		VarChar(100)					NOT NULL,
		DocName			VarCHar(1024)					NOT NULL,
		PRIMARY KEY CLUSTERED ([Id])
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @xml XML

		SET @xml = CAST(@Data AS XML)

		INSERT INTO @Documents
		SELECT
			Convert(DateTime, c.value('(@DateTime)[1]',	'VarChar(100)'), 120),
			c.value('(@Complect)[1]',	'VarChar(100)'),
			c.value('(@DocNum)',		'Int'),
			c.value('(@InfoBank)',		'VarChar(100)'),
			c.value('(.)',				'VarChar(1024)')
		FROM @xml.nodes('/ROOT/ITEM') AS a(c)

		INSERT INTO dbo.ControlDocument(DATE, RIC, SYS_NUM, DISTR, COMP, IB, IB_NUM, DOC_NAME)
		SELECT D.Dt, 20, C.SystemNumber, C.DistrNumber, C.CompNumber, D.InfoBank, D.DocNum, D.DocName
		FROM @Documents										AS D
		CROSS APPLY [dbo].[Complect@Parse](D.[Complect])	AS C
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ControlDocument b
				WHERE D.Dt = b.DATE
					AND 20 = b.RIC
					AND C.SystemNumber = b.SYS_NUM
					AND C.DistrNumber = b.DISTR
					AND C.CompNumber = b.COMP
					AND D.InfoBank = b.IB
					AND D.DocNum = b.IB_NUM
					AND D.DocName = b.DOC_NAME
			);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTROL_DOCUMENT_LOAD2] TO rl_control_document_import;
GO
