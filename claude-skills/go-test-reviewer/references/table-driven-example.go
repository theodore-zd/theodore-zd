// Canonical table-driven test pattern for Go. Recommend whenever a test file
// has three or more tests with the same structure but different inputs.

package example

import "testing"

func TestParseSize(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    int64
		wantErr bool
	}{
		{"valid bytes", "1024B", 1024, false},
		{"valid kilobytes", "5KB", 5120, false},
		{"empty string", "", 0, true},
		{"negative value", "-1B", 0, true},
		{"no unit", "1024", 0, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := ParseSize(tt.input)
			if (err != nil) != tt.wantErr {
				t.Errorf("ParseSize(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
				return
			}
			if got != tt.want {
				t.Errorf("ParseSize(%q) = %v, want %v", tt.input, got, tt.want)
			}
		})
	}
}
