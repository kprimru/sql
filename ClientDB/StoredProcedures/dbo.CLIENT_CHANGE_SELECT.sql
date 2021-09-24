USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CHANGE_SELECT]
	@BEGIN DATETIME,
	@END DATETIME,
	@MANAGER INT = NULL,
	@SERVICE INT = NULL,
	@NAME BIT = 1,
	@ADDRESS BIT = 1,
	@INN BIT = 1,
	@DIR BIT = 1,
	@DIR_PHONE BIT = 1,
	@BUH BIT = 1,
	@BUH_PHONE BIT = 1,
	@RES BIT = 1,
	@RES_PHONE BIT = 1,
	@RES_POS BIT = 1,
	@STATUS BIT = 1,
	@SCHANGE BIT = 1,
	@CLIENT INT = NULL,
	@DETAIL BIT = 0
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

		SET @BEGIN = CONVERT(DATETIME, CONVERT(VARCHAR(20), @BEGIN, 112), 112)
		SET @END = CONVERT(DATETIME, CONVERT(VARCHAR(20), @END, 112), 112)

		SET @END = DATEADD(DAY, 1, @END)

		DECLARE @LIST TABLE (ClientID INT PRIMARY KEY)

		INSERT INTO @LIST(ClientID)
			SELECT DISTINCT a.ClientID
			FROM
				dbo.ClientChangeTable a
				INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
			WHERE ChangeDate > @BEGIN
				AND ChangeDate < @end
				AND (a.ClientID = @CLIENT OR @CLIENT IS NULL)
				AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				ClientID INT,
				FLName VARCHAR(100),
				OldVal VARCHAR(500),
				NewVal VARCHAR(500),
				DT DATETIME,
				USR VARCHAR(50)
			)

		IF @NAME = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Название' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@NAME[1]', 'VARCHAR(250)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@NAME[1]', 'VARCHAR(250)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Название' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@NAME[1]', 'VARCHAR(250)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@NAME[1]', 'VARCHAR(250)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @ADDRESS = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Адрес' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@ADDRESS[1]', 'VARCHAR(250)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@ADDRESS[1]', 'VARCHAR(250)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Адрес' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@ADDRESS[1]', 'VARCHAR(250)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
									) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@ADDRESS[1]', 'VARCHAR(250)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a


		IF @INN = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'ИНН' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@INN[1]', 'VARCHAR(50)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@INN[1]', 'VARCHAR(50)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'ИНН' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@INN[1]', 'VARCHAR(50)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@INN[1]', 'VARCHAR(50)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @DIR = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Директор' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@DIR[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@DIR[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Директор' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@DIR[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@DIR[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @DIR_PHONE = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Тел.директора' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@DIR_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@DIR_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Тел.директора' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@DIR_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@DIR_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @BUH = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Гл.бух' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@BUH[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@BUH[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Гл.бух' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@BUH[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@BUH[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @BUH_PHONE = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Тел.гл.бух' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@BUH_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@BUH_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Тел.гл.бух' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@BUH_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@BUH_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @RES = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Ответственный' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@RES[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@RES[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Ответственный' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@RES[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@RES[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @RES_PHONE = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Тел.ответств.' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@RES_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@RES_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Тел.ответств.' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@RES_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@RES_PHONE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @RES_POS = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Должность.ответств.' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@RES_POS[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@RES_POS[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Должность.ответств.' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@RES_POS[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@RES_POS[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @STATUS = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Статус' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@STATUS[1]', 'VARCHAR(50)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@STATUS[1]', 'VARCHAR(50)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Статус' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@STATUS[1]', 'VARCHAR(50)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@STATUS[1]', 'VARCHAR(50)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a

		IF @SCHANGE = 1
			IF @DETAIL = 1
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT, USR)
					SELECT
						ClientID, 'Смена СИ' AS FlName,
						old.CL_NAME, new.CL_NAME, ChangeDate, ChangeUser
					FROM
						dbo.ClientChangeTable a CROSS APPLY
						(
							SELECT z.value('@SERVICE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM OldValue.nodes('/VALUES') x(z)
						) AS old CROSS APPLY
						(
							SELECT z.value('@SERVICE[1]', 'VARCHAR(150)') AS CL_NAME
							FROM NewValue.nodes('/VALUES') x(z)
						) AS new
					WHERE ChangeDate > @BEGIN
						AND ChangeDate < @end
						AND (ClientID = @CLIENT OR @CLIENT IS NULL)
			ELSE
				INSERT INTO #temp(ClientID, FLName, OldVal, NewVal, DT)
					SELECT
						ClientID, 'Смена СИ' AS FlName,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@SERVICE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM OldValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate >= @BEGIN
							ORDER BY ChangeDate
						) AS OldVal,
						(
							SELECT TOP 1 CL_NAME
							FROM
								dbo.ClientChangeTable e CROSS APPLY
								(
									SELECT z.value('@SERVICE[1]', 'VARCHAR(150)') AS CL_NAME
									FROM NewValue.nodes('/VALUES') x(z)
								) AS o_O
							WHERE e.ClientID = a.ClientID
								AND ChangeDate <= @END
							ORDER BY ChangeDate DESC
						) AS NewVal, NULL
					FROM
						@LIST AS a


		SELECT
			ClientFullName, ManagerName, ServiceName,
			(
				SELECT TOP 1
					DistrStr
				FROM
					dbo.ClientDistrView e WITH(NOEXPAND)
				WHERE e.ID_CLIENT = a.ClientID
				ORDER BY DS_INDEX, SystemOrder
			) AS DisStr, FLName, OldVal, NewVal, dt AS ChangeDate, USR AS ChangeUser
		FROM
			#temp AS a INNER JOIN
			dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		WHERE OldVal <> NewVal
		ORDER BY ClientFullName

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CHANGE_SELECT] TO rl_report_change;
GO
