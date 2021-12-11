USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ONLINE_SERVICES_DISTR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ONLINE_SERVICES_DISTR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ONLINE_SERVICES_DISTR_SELECT]
	@ClientName				NVarChar(128),
	@Distr					Int,
	@Service				SmallInt,
	@Manager				SmallInt,
	@Types					NVarChar(Max),
	@HideUnservicesDistrs	Bit,
	@HideHotlineDistrs		Bit,
	@HideExpertDistrs		Bit
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF @HideUnservicesDistrs IS NULL
			SET @HideUnservicesDistrs = 1

		IF @HideHotlineDistrs IS NULL
			SET @HideHotlineDistrs = 1

		IF @HideExpertDistrs IS NULL
			SET @HideExpertDistrs = 1

		SELECT
			ClientID,
			ClientName,
			[ServiceName] = ServiceName + ISNULL(' (' + ManagerName + ')', ''),
			DistrStr,
			HostID,
			DistrNumber,
			CompNumber,
			DS_INDEX = Cast(DS_INDEX AS Int),
			NT_SHORT,
			SST_SHORT,
			[HotlineDistrActive] = IsNull([HotlineDistrActive], 0),
			[HotlineCheckDateTime],
			[ExpertDistrActive] = IsNull([ExpertDistrActive], 0),
			[ExpertCheckDateTime]
		FROM dbo.RegNodeComplectClientView	AS R
		INNER JOIN Din.NetTypeOffline()		AS N ON N.NT_ID = R.NT_ID
		OUTER APPLY
		(
			SELECT TOP (1)
				[HotlineDistrActive]	= Cast(1 AS Bit),
				[HotlineCheckDateTime]	= HD.SET_DATE
			FROM dbo.HotlineDistr AS HD
			WHERE HD.ID_HOST = R.HostId
				AND HD.DISTR = R.DistrNumber
				AND HD.COMP = R.CompNumber
				AND HD.STATUS = 1
		) AS HD
		OUTER APPLY
		(
			SELECT TOP (1)
				[ExpertDistrActive]		= Cast(1 AS Bit),
				[ExpertCheckDateTime]	= ED.SET_DATE
			FROM dbo.ExpertDistr AS ED
			WHERE ED.ID_HOST = R.HostId
				AND ED.DISTR = R.DistrNumber
				AND ED.COMP = R.CompNumber
				AND ED.STATUS = 1
		) AS ED
		WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (DistrNumber = @DISTR OR @DISTR IS NULL)
			AND (ClientName LIKE @ClientName OR @ClientName IS NULL)
			AND (SST_SHORT IN (SELECT ID FROM dbo.TableStringFromXML(@Types)) OR @Types IS NULL)
			AND (@HideUnservicesDistrs = 1 AND DS_REG = 0 OR @HideUnservicesDistrs = 0)
			AND (@HideHotlineDistrs = 0 OR @HideHotlineDistrs = 1 AND HD.[HotlineDistrActive] IS NULL)
			AND (@HideExpertDistrs = 0 OR @HideExpertDistrs = 1 AND ED.[ExpertDistrActive] IS NULL)
		ORDER BY ServiceName, ClientName, SystemOrder, DistrNumber;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ONLINE_SERVICES_DISTR_SELECT] TO rl_expert_distr;
GO
