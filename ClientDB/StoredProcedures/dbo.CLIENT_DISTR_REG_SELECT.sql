USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISTR_REG_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, SystemOrder, DistrStr, NULL AS SystemTypeName, DistrTypeName, 
		DS_NAME, DS_REG, DS_INDEX
	FROM
		(
			SELECT ID, SystemOrder, DistrStr, DistrTypeName, DS_NAME, DS_REG, DS_INDEX
			FROM Reg.RegNodeSearchView		r WITH(NOEXPAND)
			WHERE COMPLECT = (SELECT COMPLECT FROM Reg.RegNodeSearchView WITH(NOEXPAND) WHERE ID = @ID)
			
			UNION
			
			SELECT ID, SystemOrder, DistrStr, DistrTypeName, DS_NAME, DS_REG, DS_INDEX
			FROM Reg.RegNodeSearchView		r WITH(NOEXPAND)
			WHERE ID = @ID
		) AS o_O
	ORDER BY DS_REG, SystemOrder, DistrStr
END
