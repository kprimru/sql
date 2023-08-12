USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[DISTR_EXCHANGE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[DISTR_EXCHANGE_SELECT]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [Reg].[DISTR_EXCHANGE_SELECT]
    @DateFrom	SmallDateTime	= NULL,
	@DateTo		SmallDateTime	= NULL,
	@Distr		Int				= NULL,
	@Client		VarChar(100)	= NULL
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

		IF Replace(@Client, '%', '') = ''
			SET @Client = NULL;

        IF @DateFrom IS NULL AND @DateTo IS NULL AND @Distr IS NULL AND @Client IS NULL
			SET @DateFrom = DateAdd(Month, -2, GetDate());

		SELECT
			[DistrStr]		= R.[DistrStr],
			[ClientID]		= C.[ClientID],
			[ClientName]	= IsNull(C.[ClientFullName], R.[Comment]),
			[ServiceName]	= C.[ServiceName],
			[ManagerName]	= C.[ManagerName],
			[OperDateTime]	= RH.[DATE],
			[OperType]		= RH.[Type],
			[OperValue]		= RH.[Value]
		FROM [Reg].[RegHistoryOperationDetailView] AS RH
		INNER JOIN [Reg].[RegDistr] AS RD ON RD.[ID] = RH.[ID_DISTR]
		INNER JOIN [Reg].[RegNodeSearchView] AS R WITH(NOEXPAND) ON R.[HostID] = RD.[ID_HOST] AND R.[DistrNumber] = RD.[DISTR] AND R.[CompNumber] = RD.[COMP]
		LEFT JOIN [dbo].[ClientDistrView] AS D ON D.[HostID] = RD.[ID_HOST] AND D.[DISTR] = RD.[DISTR] AND D.[COMP] = RD.[COMP]
		LEFT JOIN [dbo].[ClientView] AS C WITH(NOEXPAND) ON C.[ClientID] = D.[ID_CLIENT]
		WHERE (RH.[DATE] >= @DateFrom OR @DateFrom IS NULL)
			AND (RH.[DATE] < @DateTo OR @DateTo IS NULL)
			AND RH.Type IN ('Система', 'Сетевитость')
			AND (R.[DistrNumber] = @Distr OR @Distr IS NULL)
			AND (R.[Comment] LIKE @Client OR C.[ClientFullName] LIKE @Client OR @Client IS NULL)
		ORDER BY RH.[DATE] DESC

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Reg].[DISTR_EXCHANGE_SELECT] TO rl_reg_node_search;
GO
