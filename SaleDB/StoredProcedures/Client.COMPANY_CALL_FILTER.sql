USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_CALL_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@PERSONAL	UNIQUEIDENTIFIER,
	@MANAGER	UNIQUEIDENTIFIER,
	@TEXT		NVARCHAR(MAX),
	@RC			INT = NULL OUTPUT,
	@MEETING	INT = NULL OUTPUT,
	@ASSIGNED	INT = NULL OUTPUT,
	@SPECIFIED	INT = NULL OUTPUT,
	@REMOTE		NVARCHAR(MAX) = NULL,
	@CONTROL	BIT = 0
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
		SET @END = DATEADD(DAY, 1, @END)

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		CREATE TABLE #words
				(
					WRD		VARCHAR(250) PRIMARY KEY
				)

		IF @TEXT IS NOT NULL
			INSERT INTO #words(WRD)
				SELECT '%' + Word + '%'
				FROM Common.SplitString(@TEXT)

		IF OBJECT_ID('tempdb..#call') IS NOT NULL
			DROP TABLE #call

		CREATE TABLE #call
			(
				ID			UNIQUEIDENTIFIER,
				CO_NAME		NVARCHAR(1024),
				NUMBER		INT,
				DATE		DATETIME,
				CL_PERSONAL	NVARCHAR(512),
				NOTE		NVARCHAR(MAX),
				PER_SHORT	NVARCHAR(128),
				DATA		NVARCHAR(256),
				MEETING		TINYINT
			)

		INSERT INTO #call(ID, CO_NAME, NUMBER, DATE, CL_PERSONAL, NOTE, PER_SHORT, DATA, MEETING)
			SELECT
				b.ID AS ID,
				b.NAME AS CO_NAME, b.NUMBER, DATE, CL_PERSONAL, NOTE,
				h.SHORT AS PER_SHORT,
				ISNULL(c.SHORT + ', ', '') + ISNULL(d.SHORT + ', ', '') + ISNULL(e.SHORT, '') AS DATA,
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM Meeting.AssignedMeeting z
							WHERE z.ID_COMPANY = a.ID_COMPANY
								AND z.ID_MASTER IS NULL
								AND ISNULL(z.SPECIFY, 0) = 0
								AND z.BDATE_S = a.DATE_S
						) THEN 1
					WHEN EXISTS
						(
							SELECT *
							FROM Meeting.AssignedMeeting z
							WHERE z.ID_COMPANY = a.ID_COMPANY
								AND z.ID_MASTER IS NULL
								AND ISNULL(z.SPECIFY, 0) = 1
								AND z.BDATE_S = a.DATE_S
						) THEN 2
					ELSE 0
				END AS MEETING
			FROM
				Client.Call a
				INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
				LEFT OUTER JOIN Personal.OfficePersonal h ON ID_PERSONAL = h.ID
				LEFT OUTER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON c.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessPhoneView d WITH(NOEXPAND) ON d.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessManagerView e WITH(NOEXPAND) ON e.ID = b.ID
			WHERE --a.ID_MASTER IS NULL
				a.STATUS = 1
				AND (DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (DATE < @END OR @END IS NULL)
				AND (a.ID_PERSONAL = @PERSONAL OR @PERSONAL IS NULL)
				AND (a.ID_PERSONAL IN (SELECT ID FROM Personal.PersonalSlaveGet(@MANAGER)) OR @MANAGER IS NULL)
				AND (b.ID_REMOTE IN (SELECT ID FROM Common.TableGUIDFromXML(@REMOTE)) OR @REMOTE IS NULL)
				AND (a.CONTROL = 1 AND @CONTROL = 1 OR @CONTROL = 0 OR @CONTROL IS NULL)
				AND
					(
						@TEXT IS NULL
						OR
						NOT EXISTS
							(
								SELECT *
								FROM #words
								WHERE NOT(NOTE LIKE WRD)
							)
					)
			ORDER BY DATE DESC, CO_NAME, PER_SHORT

		SELECT @RC = @@ROWCOUNT

		SELECT ID, CO_NAME, NUMBER, DATE, CL_PERSONAL, NOTE, PER_SHORT, DATA, MEETING
		FROM #call
		ORDER BY DATE DESC, CO_NAME, PER_SHORT

		SELECT @MEETING =
			(
				SELECT COUNT(DISTINCT ID)
				FROM #call a
				WHERE MEETING <> 0
			),
			@ASSIGNED =
			(
				SELECT COUNT(DISTINCT ID)
				FROM #call a
				WHERE MEETING = 1
			),
			@SPECIFIED =
			(
				SELECT COUNT(DISTINCT ID)
				FROM #call a
				WHERE MEETING = 2
			)

		SELECT
			@MEETING = ISNULL(@MEETING, 0),
			@ASSIGNED = ISNULL(@ASSIGNED, 0),
			@SPECIFIED = ISNULL(@SPECIFIED, 0)

		IF OBJECT_ID('tempdb..#call') IS NOT NULL
			DROP TABLE #call

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_CALL_FILTER] TO rl_call_filter;
GO
