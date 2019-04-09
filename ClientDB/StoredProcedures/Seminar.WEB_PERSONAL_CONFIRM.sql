USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[WEB_PERSONAL_CONFIRM]
	@SCHEDULE	UNIQUEIDENTIFIER,
	@DISTR_S	NVARCHAR(256),
	@PSEDO		NVARCHAR(256),
	@EMAIL		NVARCHAR(256),
	@ADDRESS	NVARCHAR(256),
	@STATUS		SMALLINT OUTPUT,
	@MSG		NVARCHAR(2048) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @HOST INT
	DECLARE @DISTR INT
	DECLARE @COMP TINYINT

	EXEC Seminar.WEB_DISTR_CHECK @SCHEDULE, @DISTR_S, @MSG OUTPUT, @STATUS OUTPUT, @HOST OUTPUT, @DISTR	OUTPUT, @COMP OUTPUT

	IF @STATUS = 0
	BEGIN
	
		INSERT INTO Seminar.Personal(ID_SCHEDULE, ID_CLIENT, PSEDO, EMAIL, ID_STATUS, ADDRESS)
			SELECT 
				@SCHEDULE, ID_CLIENT, @PSEDO, @EMAIL,
				CASE 
					WHEN (SELECT LIMIT FROM Seminar.Schedule WHERE ID = @SCHEDULE) > 
							(
								SELECT COUNT(*) 
								FROM 
									Seminar.Personal a
									INNER JOIN Seminar.Status b ON a.ID_STATUS = b.ID
								WHERE ID_SCHEDULE = @SCHEDULE AND b.INDX = 1 AND a.STATUS = 1 
							) THEN 
					(
						SELECT ID 
						FROM Seminar.Status
						WHERE INDX = 1
					)
					ELSE
					(
						SELECT ID 
						FROM Seminar.Status
						--WHERE INDX = 2
						-- это не даст записываться в резервный список
						WHERE INDX = 10
					)
				END,
					@ADDRESS
			FROM dbo.ClientDistrView WITH(NOEXPAND)
			WHERE HostID = @HOST 
				AND DISTR = @DISTR 
				AND COMP = @COMP
				
		IF @@ROWCOUNT = 0
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Вы не зарегистрированы в нашей базе как клиент.'
		END
	END
END
