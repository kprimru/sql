USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[ZVE_USR]
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

		SELECT DISTINCT
			ManagerName AS [���-��], ServiceName AS [��], ClientFullName AS [������],
			b.DistrStr AS [�����������], b.DistrTypeName AS [����],
			T.UF_EXPCONS AS [����-����� ����� � ��������� �������],
			SET_DATE AS [����-����� ����������� ������� � ������ ���],
			dbo.DateOf(
				(
					SELECT MAX(DATE)
					FROM
						dbo.ClientDutyQuestion z
						INNER JOIN dbo.SystemTable y ON z.SYS = y.SystemNumber
					WHERE z.DISTR = b.DISTR AND z.COMP = b.COMP AND y.HostID = b.HostID
				)
			) AS [���� ���������� �������]
		FROM
			USR.USRComplectNumberView a WITH(NOEXPAND)
			INNER JOIN USR.USRData c ON a.UD_ID = c.UD_ID
			INNER JOIN dbo.SystemTable d ON d.SystemNumber = a.UD_SYS
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON d.HostID = b.HostID AND a.UD_DISTR = b.DISTR AND a.UD_COMP = b.COMP
			INNER JOIN Din.NetType n ON n.NT_ID_MASTER = b.DistrTypeID
			INNER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = c.UD_ID_CLIENT
			INNER JOIN USR.USRActiveView f ON f.UD_ID = c.UD_ID
			INNER JOIN USR.USRFile g ON g.UF_ID = f.UF_ID
			INNER JOIN USR.USRFileTech t ON t.UF_ID = g.UF_ID
			INNER JOIN dbo.ExpertDistr h ON h.ID_HOST = b.HostID AND h.DISTR = b.DISTR AND h.COMP = b.COMP
		WHERE c.UD_ACTIVE = 1 AND h.UNSET_DATE IS NULL
			AND n.NT_TECH IN (0, 1)
			AND
				(
					T.UF_EXPCONS IS NULL AND T.UF_FORMAT >= 11
					OR
					T.UF_EXPCONS_KIND IN ('N')
				)
		ORDER BY ManagerName, ServiceName, ClientFullname

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[ZVE_USR] TO rl_report;
GO