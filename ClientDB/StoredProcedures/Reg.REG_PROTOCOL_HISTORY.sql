USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Reg].[REG_PROTOCOL_HISTORY]
	@Host			SmallInt,
	@Distr			Int,
	@Comp			TinyInt
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

		DECLARE @IDs	Table
		(
			Id		BigInt	NOT NULL PRIMARY KEY CLUSTERED
		);

		INSERT INTO @IDs
		SELECT TOP (1000) P.RPR_ID
		FROM dbo.RegProtocol P
		WHERE	RPR_DISTR = @Distr
			AND	RPR_ID_HOST = @Host
			AND RPR_COMP = @Comp
		ORDER BY RPR_DATE DESC
		OPTION (RECOMPILE)

		SELECT
			RPR_DATE,
			NT_SHORT, SST_SHORT, DS_INDEX, COMMENT, COMPLECT,
			RPR_OPER, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER
		FROM @IDs					I
		INNER JOIN dbo.RegProtocol	R ON I.ID = R.RPR_ID
		OUTER APPLY
		(
			SELECT
				[SystemShortName]	= IsNull(H.SystemShortName, P.SystemShortName),
				[NT_SHORT]			= IsNull(H.NT_SHORT, P.NT_SHORT),
				[SST_SHORT]			= IsNull(H.SST_SHORT, P.SST_SHORT),
				[DS_INDEX]			= IsNull(H.DS_INDEX, P.DS_INDEX),
				[COMMENT]			= IsNull(H.COMMENT, P.COMMENT),
				[COMPLECT]			= IsNull(H.COMPLECT, P.COMPLECT)
			FROM (SELECT [E] = 1) F
			OUTER APPLY
			(
				SELECT TOP(1)
					H.SystemShortName,
					H.NT_SHORT,
					H.SST_SHORT,
					S.DS_INDEX,
					H.COMMENT,
					H.COMPLECT
				FROM Reg.RegDistr				D
				INNER JOIN Reg.RegHistoryView	H WITH(NOEXPAND) ON H.ID_DISTR = D.ID
				INNER JOIN dbo.DistrStatus		S ON S.DS_REG = H.DS_REG
				WHERE D.ID_HOST = R.RPR_ID_HOST
					AND D.DISTR = R.RPR_DISTR
					AND D.COMP = R.RPR_COMP
					AND H.DATE >= R.RPR_DATE
				ORDER BY H.DATE
			) H
			OUTER APPLY
			(
				SELECT TOP(1)
					H.SystemShortName,
					H.NT_SHORT,
					H.SST_SHORT,
					S.DS_INDEX,
					H.COMMENT,
					H.COMPLECT
				FROM Reg.RegDistr				D
				INNER JOIN Reg.RegHistoryView	H WITH(NOEXPAND) ON H.ID_DISTR = D.ID
				INNER JOIN dbo.DistrStatus		S ON S.DS_REG = H.DS_REG
				WHERE D.ID_HOST = R.RPR_ID_HOST
					AND D.DISTR = R.RPR_DISTR
					AND D.COMP = R.RPR_COMP
					AND H.DATE <= R.RPR_DATE
				ORDER BY H.DATE DESC
			) P
		) H
		ORDER BY R.RPR_DATE DESC
		OPTION(RECOMPILE)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[REG_PROTOCOL_HISTORY] TO rl_reg_protocol_filter;
GO
