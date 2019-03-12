USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DUTY_IB_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SystemID, SystemShortName, 
		CASE 
			WHEN Checked > 0 THEN CONVERT(BIT, 1)
			ELSE CONVERT(BIT, 0)
		END AS Checked
	FROM
		(
			SELECT 
				SystemID, SystemShortName, SystemOrder,
				(
					SELECT COUNT(*)
					FROM dbo.ClientDutyIBTable b 
					WHERE b.ClientDutyID = @ID
						AND a.SystemID = b.SystemID 
				) AS Checked
			FROM dbo.SystemTable a
		) AS o_O
	ORDER BY SystemOrder
END