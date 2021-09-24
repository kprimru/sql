USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[ZVE_SUBHOST_EXTENDED]
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
			SH_CAPTION AS [�������], ClientName AS [������], DistrStr AS [�����������], RPR_DATE_S AS [���� �����������], NT_SHORT AS [����], SST_SHORT AS [��� �������],
			(
				SELECT COUNT(*)
				FROM
					dbo.ClientDutyQuestion a
					INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
				WHERE a.DISTR = DistrNumber AND a.COMP = CompNumber AND c.HostID = o_O.HostID
			) AS [���-�� ��������]
		FROM
			(
				SELECT SH_CAPTION, SH_NAME, ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder, RPR_DATE_S
				FROM
					(
						SELECT '�����������' AS SH_CAPTION, '' AS SH_NAME
						UNION ALL
						SELECT '��������' AS CAPTION, '�1' AS SubhostName
						UNION ALL
						SELECT '�������' AS CAPTION, '�1' AS SubhostName
						UNION ALL
						SELECT '���������' AS CAPTION, '�1' AS SubhostName
						UNION ALL
						SELECT '�����' AS CAPTION, '�' AS SubhostName
					) AS SH
					CROSS APPLY
					(
						SELECT ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder
						FROM dbo.RegNodeComplectClientView
						WHERE SubhostName = SH_NAME
							AND DS_REG = 0
					) AS CLIENT
					CROSS APPLY
					(
						SELECT TOP (1) RPR_DATE_S
						FROM dbo.RegProtocol  AS P
						WHERE P.RPR_ID_HOST = Client.HostID
							AND P.RPR_DISTR = Client.DIstrNumber
							AND P.RPR_COMP = Client.CompNumber
						ORDER BY RPR_DATE_S
					) AS P
			) AS o_O
		ORDER BY SH_NAME, SystemOrder, DistrNumber, CompNumber, ClientName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[ZVE_SUBHOST_EXTENDED] TO rl_report;
GO
