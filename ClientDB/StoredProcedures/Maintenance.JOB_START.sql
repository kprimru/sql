USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[JOB_START]
	@Name	VarChar(100),
	@Id		BigInt = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Type_Id	SmallInt;
	
	SELECT @Type_Id = Id
	FROM Maintenance.JobType
	WHERE Name = @Name;
	
	IF @Type_Id IS NULL BEGIN
		INSERT INTO Maintenance.JobType(Name)
		VALUES(@Name);
		
		SELECT @Type_Id = Scope_Identity();
	END;

	INSERT INTO Maintenance.Jobs([Type_Id])
	VALUES(@Type_Id);
	
	SELECT @Id = Scope_Identity();
END
