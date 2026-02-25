import { LightningElement, track } from 'lwc';

export default class WorkOrderPlayer extends LightningElement {
    @track isPlaying = false;
    @track currentTrackIndex = 0;

    // Simulated playlist
    tracks = [
        'Work Order #001 - Oil Change',
        'Work Order #002 - Tire Rotation',
        'Work Order #003 - Brake Inspection',
        'Work Order #004 - Battery Check'
    ];

    get currentTrack() {
        return this.tracks[this.currentTrackIndex];
    }

    get playPauseIcon() {
        return this.isPlaying ? 'utility:pause' : 'utility:play';
    }

    get playPauseTitle() {
        return this.isPlaying ? 'Pause' : 'Play';
    }

    get playerStatus() {
        return this.isPlaying ? 'Processing...' : 'Ready to start';
    }

    handlePrev() {
        if (this.currentTrackIndex > 0) {
            this.currentTrackIndex--;
        } else {
            this.currentTrackIndex = this.tracks.length - 1; // Loop to end
        }
        // If it was playing, keep playing new track
    }

    handlePlayPause() {
        this.isPlaying = !this.isPlaying;
    }

    handleNext() {
        if (this.currentTrackIndex < this.tracks.length - 1) {
            this.currentTrackIndex++;
        } else {
            this.currentTrackIndex = 0; // Loop to start
        }
    }
}