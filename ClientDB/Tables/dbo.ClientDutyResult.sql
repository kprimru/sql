USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDutyResult]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_DUTY]       Int                   NOT NULL,
        [ANSWER]        TinyInt               NOT NULL,
        [ANSWER_NOTE]   NVarChar(Max)         NOT NULL,
        [SATISF]        TinyInt               NOT NULL,
        [SATISF_NOTE]   NVarChar(Max)         NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDutyResult] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientDutyResult(ID_DUTY)_dbo.ClientDutyTable(ClientDutyID)] FOREIGN KEY  ([ID_DUTY]) REFERENCES [dbo].[ClientDutyTable] ([ClientDutyID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyResult(ID_DUTY,STATUS)+(ANSWER,SATISF,UPD_DATE,UPD_USER)] ON [dbo].[ClientDutyResult] ([ID_DUTY] ASC, [STATUS] ASC) INCLUDE ([ANSWER], [SATISF], [UPD_DATE], [UPD_USER]);
GO
