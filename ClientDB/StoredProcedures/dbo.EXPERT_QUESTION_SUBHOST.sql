USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EXPERT_QUESTION_SUBHOST]
	@SUBHOST	UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE @SubhostQuestions Table
	(
		Id			UniqueIdentifier	NOT NULL,
		SH_EMAIL	VarChar(100)		NOT NULL,
		PRIMARY KEY CLUSTERED(Id)	
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @SubhostQuestions
		SELECT
			Q.Id, SH_EMAIL
		FROM
		(
			SELECT
				SH_ID		= SH_ID,
				SH_EMAIL	= SH_EMAIL
			FROM dbo.Subhost
			WHERE SH_REG IN ('Ì', 'Ó1', 'Í1')
		) AS SH
		CROSS APPLY [dbo].[SubhostDistrs@Get](SH.SH_ID, NULL)	AS D
		INNER JOIN dbo.SystemTable								AS S ON D.[HostId] = S.[HostID]
		INNER JOIN dbo.ClientDutyQuestion						AS Q ON Q.SYS = S.SystemNumber AND Q.DISTR = D.DistrNumber AND D.CompNumber = Q.COMP
		WHERE Q.SUBHOST IS NULL

		SELECT 
			Q.ID, SYS, DISTR, COMP, DATE, FIO, EMAIL, PHONE, QUEST, SH_EMAIL,
			CONVERT(NVARCHAR(16), SYS) + '_' + CONVERT(NVARCHAR(16), DISTR) + 
				CASE COMP 
					WHEN 1 THEN '' 
					ELSE '_' + CONVERT(NVARCHAR(8), COMP) 
				END AS COMPLECT,
			(
				SELECT 
					SYS AS '@sys', DISTR AS '@distr', COMP AS '@comp', CONVERT(NVARCHAR(64), DATE, 120) AS '@date', 
					FIO AS 'fio', EMAIL AS 'email', PHONE AS 'phone', QUEST AS 'text'
				FROM dbo.ClientDutyQuestion z
				WHERE z.ID = Q.ID
				FOR XML PATH('quest'), ROOT('root')
			) AS QUEST_XML
		FROM @SubhostQuestions				AS SQ
		INNER JOIN dbo.ClientDutyQuestion	AS Q	ON SQ.Id = Q.ID;
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
