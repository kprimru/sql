USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[PRICE_LETTER]
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
			ServiceName AS [��],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('���', '����')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|���-����],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('1/�')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|1/�],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('�/�')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|�/�],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('����')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|����],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('���')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|���],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('����')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|����],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('���')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|���],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('���1')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|���1],
			(
				SELECT COUNT(DISTINCT ClientID)
				FROM dbo.ClientDistrView b WITH(NOEXPAND)
				INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.CLientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON c.ServiceStatusId = s.ServiceStatusId
				WHERE a.ServiceID = c.ServiceID
					AND b.DS_REG = 0
					AND DistrTypeName IN ('���2')
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.DBFDistrFinancingView z
							WHERE b.SystemBaseName = z.SYS_REG_NAME
								AND b.DISTR = z.DIS_NUM
								AND b.COMP = z.DIS_COMP_NUM
								AND DF_FIXED_PRICE <> 0
						)
			) AS [���������� �������� ��� ������������� ���������|���2]
		FROM dbo.ServiceTable a
		WHERE EXISTS
			(
				SELECT *
				FROM dbo.ClientTable z
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
				WHERE ServiceID = ClientServiceID
					AND STATUS = 1
			)
		ORDER BY ServiceName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[PRICE_LETTER] TO rl_report;
GO
