USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[SCHEDULE_PERSONAL_ACTIVE]
	@ID			UNIQUEIDENTIFIER,
	@SCHEDULE	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	IF (
			SELECT COUNT(*) 
			FROM 
				Seminar.PersonalView WITH(NOEXPAND)
			WHERE ID_SCHEDULE = @SCHEDULE AND INDX = 1
		) >= 
		(
			SELECT LIMIT
			FROM Seminar.Schedule
			WHERE ID = @SCHEDULE
		)
	BEGIN
		RAISERROR ('��� �������� ������������ ���������� ����������. ����� �������� ������ � ������.', 16, 1)
		RETURN
	END
	
	IF (SELECT INDX FROM Seminar.PersonalView WITH(NOEXPAND) WHERE ID = @ID) = 1
	BEGIN
		RAISERROR ('��������� � ��� ��������� � �������� ������', 16, 1)
		RETURN
	END
	
	EXEC Seminar.SCHEDULE_PERSONAL_ARCH @ID
	
	UPDATE Seminar.Personal
	SET ID_SCHEDULE	=	@SCHEDULE,
		ID_STATUS	=	(SELECT ID FROM Seminar.Status WHERE INDX = 1),
		UPD_DATE	=	GETDATE(),
		UPD_USER	=	ORIGINAL_LOGIN()
	WHERE ID = @ID
END
