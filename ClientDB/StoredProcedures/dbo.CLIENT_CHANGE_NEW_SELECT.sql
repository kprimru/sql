﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CHANGE_NEW_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CHANGE_NEW_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CHANGE_NEW_SELECT]
	@BEGIN DATETIME,
	@END DATETIME,
	@MANAGER INT = NULL,
	@SERVICE INT = NULL,
	@CLIENT INT = NULL,
	@DETAIL BIT = 0,
	@NAME BIT = 1,
	@ADDRESS BIT = 1,
	@INN BIT = 1,
	@DIR BIT = 1,
	@DIR_POS BIT = 1,
	@DIR_PHONE BIT = 1,
	@BUH BIT = 1,
	@BUH_POS BIT = 1,
	@BUH_PHONE BIT = 1,
	@RES BIT = 1,
	@RES_POS BIT = 1,
	@RES_PHONE BIT = 1,
	@SCHANGE BIT = 1
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

		IF @BEGIN < '20130701'
			SET @BEGIN = '20130701'

		SET @END = DATEADD(DAY, 1, @END)

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF OBJECT_ID('tempdb..#change') IS NOT NULL
			DROP TABLE #change

		CREATE TABLE #change
			(
				ClientID		INT,
				FieldName		VARCHAR(100),
				FieldOrder		INT,
				OldValue		VARCHAR(255),
				NewValue		VARCHAR(255),
				UpdateDate		DATETIME,
				UserName		VARCHAR(128)
			)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client(ID INT PRIMARY KEY)

		IF @CLIENT IS NULL
			INSERT INTO #client(ID)
				SELECT DISTINCT ID_MASTER
				FROM
					dbo.ClientTable a
					INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_MASTER = b.ClientID
				WHERE ClientLast >= @BEGIN AND ClientLast < @END
					AND ID_MASTER IS NOT NULL
					AND (b.ServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (b.ManagerID = @MANAGER OR @MANAGER IS NULL)
		ELSE
			INSERT INTO #client(ID)
				SELECT @CLIENT

		IF @NAME = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Название', 1,
						(
							SELECT TOP 1 ClientFullName
							FROM dbo.ClientUpdateView z WITH(NOEXPAND)
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.ClientFullName,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientTable b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Название', 1,
						b.ClientFullName,
						c.ClientFullName,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 ClientFullName, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 ClientFullName
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.ClientFullName != b.ClientFullName
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @INN = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ИНН', 2,
						(
							SELECT TOP 1 ClientINN
							FROM dbo.ClientUpdateView z WITH(NOEXPAND)
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.ClientINN,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientTable b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ИНН', 2,
						b.ClientINN,
						c.ClientINN,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 ClientINN, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 ClientINN
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.ClientINN != b.ClientINN
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @ADDRESS = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Адрес', 3,
						(
							SELECT TOP 1 CA_STR
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.CA_STR,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Адрес', 3,
						b.CA_STR,
						c.CA_STR,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 CA_STR, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 CA_STR
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.CA_STR != b.CA_STR
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @DIR = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ФИО руководителя', 4,
						(
							SELECT TOP 1 DIR_FIO
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.DIR_FIO,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ФИО руководителя', 4,
						b.DIR_FIO,
						c.DIR_FIO,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 DIR_FIO, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 DIR_FIO
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.DIR_FIO != b.DIR_FIO
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @DIR_POS = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Должность руководителя', 5,
						(
							SELECT TOP 1 DIR_POS
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.DIR_POS,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Должность руководителя', 5,
						b.DIR_POS,
						c.DIR_POS,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 DIR_POS, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 DIR_POS
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.DIR_POS != b.DIR_POS
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @DIR_PHONE = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Телефон руководителя', 6,
						(
							SELECT TOP 1 DIR_PHONE
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.DIR_PHONE,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Телефон руководителя', 6,
						b.DIR_PHONE,
						c.DIR_PHONE,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 DIR_PHONE, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 DIR_PHONE
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.DIR_PHONE != b.DIR_PHONE
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @BUH = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ФИО гл.бух.', 7,
						(
							SELECT TOP 1 BUH_FIO
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.BUH_FIO,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ФИО гл.бух.', 7,
						b.BUH_FIO,
						c.BUH_FIO,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 BUH_FIO, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 BUH_FIO
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.BUH_FIO != b.BUH_FIO
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @BUH_POS = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Должность гл.бух.', 8,
						(
							SELECT TOP 1 BUH_POS
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.BUH_POS,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Должность гл.бух.', 8,
						b.BUH_POS,
						c.BUH_POS,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 BUH_POS, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 BUH_POS
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.BUH_POS != b.BUH_POS
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @BUH_PHONE = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Телефон гл.бух.', 9,
						(
							SELECT TOP 1 BUH_PHONE
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.BUH_PHONE,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Телефон гл.бух.', 9,
						b.BUH_PHONE,
						c.BUH_PHONE,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 BUH_PHONE, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 BUH_PHONE
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.BUH_PHONE != b.BUH_PHONE
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @RES = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ФИО ответственного', 10,
						(
							SELECT TOP 1 RES_FIO
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.RES_FIO,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'ФИО ответственного', 10,
						b.RES_FIO,
						c.RES_FIO,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 RES_FIO, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 RES_FIO
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.RES_FIO != b.RES_FIO
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @RES_POS = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Должность ответственного', 11,
						(
							SELECT TOP 1 RES_POS
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.RES_POS,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Должность ответственного', 11,
						b.RES_POS,
						c.RES_POS,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 RES_POS, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 RES_POS
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.RES_POS != b.RES_POS
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END

		IF @RES_PHONE = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Телефон ответственного', 12,
						(
							SELECT TOP 1 RES_PHONE
							FROM dbo.ClientEditionView z
							WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
								AND z.ClientLast < b.ClientLast
							ORDER BY ClientLast DESC
						),
						b.RES_PHONE,
						ClientLast, UPD_USER
					FROM
						#client a
						INNER JOIN dbo.ClientEditionView b ON a.ID = b.ID_MASTER OR a.ID = b.ClientID
					WHERE dbo.DateOf(ClientLast) >= @BEGIN
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Телефон ответственного', 12,
						b.RES_PHONE,
						c.RES_PHONE,
						z.ClientLast, z.UPD_USER
					FROM #client a
					OUTER APPLY
					(
						SELECT TOP 1 RES_PHONE, ClientLast
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast <= @BEGIN
						ORDER BY ClientLast DESC
					) AS b
					OUTER APPLY
					(
						SELECT TOP 1 RES_PHONE
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
						ORDER BY ClientLast DESC
					) AS c
					OUTER APPLY
					(
						SELECT TOP 1 ClientLast,UPD_USER
						FROM dbo.ClientEditionView z
						WHERE (z.ClientID = a.ID OR z.ID_MASTER = a.ID)
							AND ClientLast < @END
							AND z.RES_PHONE != b.RES_PHONE
							AND z.ClientLast > b.CLientLast
						ORDER BY ClientLast
					) AS Z
		END


		IF @SCHANGE = 1
		BEGIN
			IF @DETAIL = 1
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Сервис-инженер', 13,
						(
							SELECT TOP 1 ServiceName
							FROM
								dbo.ClientService z
								INNER JOIN dbo.ServiceTable y ON y.ServiceID = z.ID_SERVICE
							WHERE z.ID_CLIENT = a.ID
								AND z.UPD_DATE < b.UPD_DATE
							ORDER BY UPD_DATE DESC
						),
						c.ServiceName,
						UPD_DATE, US_NAME
					FROM
						#client a
						INNER JOIN dbo.ClientService b ON a.ID = b.ID_CLIENT
						INNER JOIN dbo.ServiceTable c ON c.ServiceID = b.ID_SERVICE
			ELSE
				INSERT INTO #change(ClientID, FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName)
					SELECT
						a.ID,
						'Сервис-инженер', 13,
						ISNULL((
							SELECT TOP 1 ServiceName
							FROM
								dbo.ClientService z
								INNER JOIN dbo.ServiceTable y ON y.ServiceID = z.ID_SERVICE
							WHERE z.ID_CLIENT = a.ID
								AND z.UPD_DATE <= @BEGIN
							ORDER BY UPD_DATE DESC
						),
						(
							SELECT TOP 1 ServiceName
							FROM
								dbo.ClientService z
								INNER JOIN dbo.ServiceTable y ON y.ServiceID = z.ID_SERVICE
							WHERE z.ID_CLIENT = a.ID
								AND z.UPD_DATE >= @BEGIN
							ORDER BY UPD_DATE
						)
						),
						(
							SELECT TOP 1 ServiceName
							FROM
								dbo.ClientService z
								INNER JOIN dbo.ServiceTable y ON y.ServiceID = z.ID_SERVICE
							WHERE z.ID_CLIENT = a.ID
								AND z.UPD_DATE < @END
							ORDER BY UPD_DATE DESC
						),
						NULL AS UPD_DATE, NULL AS US_NAME
					FROM
						#client a
		END

		/*DELETE FROM #change WHERE OldValue IS NULL*/

		SELECT
			a.ClientID, b.ClientFullName, b.ServiceName, b.ManagerName,
			(
				SELECT TOP 1 DistrStr
				FROM dbo.ClientDistrView z WITH(NOEXPAND)
				WHERE z.ID_CLIENT = b.ClientID
				ORDER BY DS_REG, SystemOrder, DISTR
			) AS DistrStr,
			FieldName, FieldOrder, OldValue, NewValue, UpdateDate, UserName
		FROM
			#change a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		WHERE ISNULL(OldValue, '') <> ISNULL(NewValue, '')
			AND OldValue IS NOT NULL
		ORDER BY ClientFullName, ClientID, FieldOrder, FieldName, UpdateDate

		IF OBJECT_ID('tempdb..#change') IS NOT NULL
			DROP TABLE #change

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CHANGE_NEW_SELECT] TO rl_report_change;
GO
