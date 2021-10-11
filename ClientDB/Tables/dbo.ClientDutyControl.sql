USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDutyControl]
(
        [CDC_ID]        UniqueIdentifier      NOT NULL,
        [CDC_ID_CALL]   UniqueIdentifier      NOT NULL,
        [CDC_ANSWER]    TinyInt               NOT NULL,
        [CDC_SATISF]    TinyInt               NOT NULL,
        [CDC_NOTE]      NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDutyControl] PRIMARY KEY CLUSTERED ([CDC_ID]),
        CONSTRAINT [FK_dbo.ClientDutyControl(CDC_ID_CALL)_dbo.ClientCall(CC_ID)] FOREIGN KEY  ([CDC_ID_CALL]) REFERENCES [dbo].[ClientCall] ([CC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyControl(CDC_SATISF,CDC_ID_CALL)] ON [dbo].[ClientDutyControl] ([CDC_SATISF] ASC, [CDC_ID_CALL] ASC);
GO
