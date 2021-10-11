USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_CALL_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@DEL	BIT = 0,
	@RC		INT = NULL OUTPUT,
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
		SELECT
			a.ID, [Claim_Id] = Cast(NULL AS Int), [ClaimActionIndex] = Cast(NULL AS TinyInt), b.SHORT, b.NAME, CL_PERSONAL, c.SHORT AS PER_SHORT, DATE, NOTE,
			CONVERT(BIT,
				(
					SELECT COUNT(*)
					FROM Meeting.AssignedMeeting
					WHERE ID_CALL = @ID
				)
			) AS CALL_MEETING,
			a.STATUS,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE
			) AS CREATE_DATA,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE DESC
			) AS UPDATE_DATA,
			CASE a.STATUS
				WHEN 3 THEN CONVERT(VARCHAR(20), a.EDATE, 104) + ' ' + CONVERT(VARCHAR(20), a.EDATE, 108) + '/' + a.UPD_USER
				ELSE ''
			END AS DELETE_DATA
		FROM
			Client.Call a
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_PERSONAL
			LEFT OUTER JOIN Client.Office b ON a.ID_OFFICE = b.ID
		WHERE a.ID_COMPANY = @ID
			AND (a.STATUS = 1 OR a.STATUS = 3 AND @DEL = 1)
			AND (@CONTROL = 0 OR CONTROL = 1 AND @CONTROL = 1 OR @CONTROL IS NULL)

		UNION ALL

		SELECT
		    NewId(), C.[Id], CA.[Index],
		    NULL, NULL, NULL,
		    --Cast(C.[Number] AS VarChar(256)), Cast(C.[Number] AS VarChar(256)), NULL,
		    P.[SHORT], CA.[DateTime], CA.[Note], CA.[Meeting], 1, NULL, NULL, NULL
		FROM [Claim].[Claims] AS C
		INNER JOIN [Claim].[Claims:Actions] AS CA ON C.[Id] = CA.[Claim_Id]
		INNER JOIN [Personal].[OfficePersonal] AS P ON CA.[Personal_Id] = P.[Id]
		WHERE C.[Company_Id] = @ID

		ORDER BY DATE DESC

		SELECT @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_CALL_SELECT] TO rl_call_r;
GO
