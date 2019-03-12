USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONNECT_STUDY_FILTER]
	@MANAGER	NVARCHAR(MAX),
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		NVARCHAR(MAX),
	@STUDY		BIT,
	@CLAIM		BIT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	SELECT ClientID, ClientFullName, ManagerName, ServiceName, DATE, LAST_STUDY, LAST_STUDY_CLAIM, RPR_TEXT
	FROM
		(
			SELECT 
				ClientID, ClientFullName, ManagerName, ServiceName, DATE, RPR_TEXT,
				(
					SELECT MAX(DATE)
					FROM 
						dbo.ClientStudy z
						INNER JOIN dbo.LessonPlaceTable ON ID_PLACE = LessonPlaceID
					WHERE z.STATUS = 1 AND z.ID_CLIENT = a.ClientID AND Teached = 1
						AND LessonPlaceName NOT IN ('��', '�������')
				) AS LAST_STUDY,
				(
					SELECT MAX(DATE)
					FROM dbo.ClientStudyClaim z
					WHERE z.ID_CLIENT = a.ClientID
				) AS LAST_STUDY_CLAIM
			FROM
				(
					SELECT a.ClientID, b.ClientFullName, b.ManagerName, b.ServiceName, DATE, RPR_TEXT
					FROM 
						dbo.ClientStudyConnectView a
						INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
						INNER JOIN dbo.ClientTable c ON c.ClientID = b.ClientID
						INNER JOIN dbo.TableIDFromXML(@TYPE) d ON d.ID = c.ClientContractTypeID
					WHERE (DATE >= @BEGIN OR @BEGIN IS NULL)
						AND (DATE <= @END OR @END IS NULL)
						AND (b.ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
						AND (b.ServiceID = @SERVICE OR @SERVICE IS NULL)
				) AS a
		) AS o_O
	WHERE (@STUDY = 0 OR @STUDY = 1 AND DATE > ISNULL(LAST_STUDY, DATEADD(DAY, -1, DATE)))
		AND (@CLAIM = 0 OR @CLAIM = 1 AND DATE > ISNULL(LAST_STUDY_CLAIM, DATEADD(DAY, -1, DATE)))
	ORDER BY DATE DESC, ManagerName, ServiceName, ClientFullName
END
