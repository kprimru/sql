USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[OVMF_COMPETITION]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT
			[№ в группе] = Row_Number() OVER(PARTITION BY IsNull(C.ServiceName, R.SubhostName) ORDER BY IsNull(C.ClientFullName, R.Comment)),
			[Клиент] = IsNull(C.ClientFullName, R.Comment),
			[СИ/Подхост] = IsNull(C.ServiceName, R.SubhostName),
			[Дистрибутив] = R.DistrStr,
			[Дата регистрации] = P.RPR_DATE
		FROM
		(
			SELECT DISTINCT RPR_ID_HOST, RPR_DISTR, RPR_COMP, MAX(RPR_DATE_S) AS RPR_DATE
			FROM dbo.RegProtocol
			WHERE RPR_DATE >= '20180701'
				AND RPR_DATE < '20181001'
				AND RPR_TEXT = 'Тех. тип. Старое значение:0. Новое:11'
				--AND RPR_DISTR = 32957
				AND RPR_ID_HOST = 1
			GROUP BY RPR_ID_HOST, RPR_DISTR, RPR_COMP
		) AS P
		INNER JOIN Reg.RegNodeSearchView R WITH(NOEXPAND) ON P.RPR_ID_HOST = R.HostId AND RPR_DISTR = R.DistrNumber AND p.RPR_COMP = R.CompNumber
		LEFT JOIN dbo.ClientDistrView D WITH(NOEXPAND) ON D.HostId = R.HostId AND D.DISTR = R.DistrNumber AND D.COMP = R.CompNumber
		LEFT JOIN dbo.ClientView C WITH(NOEXPAND) ON C.ClientID = D.ID_CLIENT
		ORDER BY C.ServiceName, IsNull(C.ServiceName, R.SubhostName), IsNull(C.ClientFullName, R.Comment)
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
