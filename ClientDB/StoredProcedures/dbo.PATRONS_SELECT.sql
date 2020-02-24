USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PATRONS_SELECT]
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

		SELECT DISTINCT LTRIM(RTRIM(CP_PATRON)) AS CP_PATRON
		FROM
			(
				SELECT DISTINCT CP_PATRON
				FROM 
					dbo.ClientTable a
					INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
					INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
				WHERE a.STATUS = 1 AND CP_PATRON <> '' AND CP_PATRON <> '-'
				/*
				UNION 

				SELECT DISTINCT SSP_PATRON
				FROM Training.SeminarSignPersonal
				WHERE SSP_PATRON <> '' AND SSP_PATRON <> '-'
				*/
				/*
				UNION
				
				SELECT DISTINCT PATRON
				FROM 
					dbo.ClientStudyPeople a
					INNER JOIN dbo.ClientStudy b ON a.ID_STUDY = b.ID
				WHERE b.STATUS = 1
				
				UNION
				
				SELECT DISTINCT PATRON
				FROM 
					dbo.ClientStudyClaimPeople a
					INNER JOIN dbo.ClientStudyClaim b ON a.ID_CLAIM = b.ID
				WHERE b.STATUS = 1
				*/
			) AS o_O
		ORDER BY CP_PATRON
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
