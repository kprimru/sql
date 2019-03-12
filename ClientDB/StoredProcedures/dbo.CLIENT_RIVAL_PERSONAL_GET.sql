USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_RIVAL_PERSONAL_GET]
	@CR_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		PositionTypeID, PositionTypeName, 
		CONVERT(BIT, 
			ISNULL(
				(
					SELECT COUNT(*)
					FROM dbo.ClientRivalPersonal 
					WHERE CRP_ID_PERSONAL = PositionTypeID
						AND CRP_ID_RIVAL = @CR_ID
				), 0)
		) AS PositionTypeChecked
	FROM 
		dbo.PositionTypeTable
	ORDER BY PositionTypeName
END